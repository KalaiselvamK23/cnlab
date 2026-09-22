import java.io.*;
import java.net.*;

public class SecureClient {

    static final String SERVER = "localhost";

    static final int PORT = 4567;

    static final int KEY = 3;

    static final String CLIENT_FOLDER =
            "ClientFiles";


    // ENCRYPT
    static byte encrypt(byte b) {

        return (byte)((b + KEY) % 256);
    }


    // DECRYPT
    static byte decrypt(byte b) {

        return (byte)((b - KEY + 256) % 256);
    }


    // LIST FILES
    static void listFiles() throws Exception {

        Socket s =
                new Socket(SERVER, PORT);


        DataInputStream in =
                new DataInputStream(
                        s.getInputStream());

        DataOutputStream out =
                new DataOutputStream(
                        s.getOutputStream());


        out.writeUTF("LIST");


        int count =
                in.readInt();


        System.out.println(
                "\nFiles on server:");


        for (int i = 0; i < count; i++) {

            System.out.println(
                    in.readUTF());
        }


        s.close();
    }


    // UPLOAD FILE
    static void uploadFile(String fileName)
            throws Exception {

        File file =
                new File(
                        CLIENT_FOLDER,
                        fileName);


        if (!file.exists()) {

            System.out.println(
                    "File not found.");

            return;
        }


        Socket s =
                new Socket(SERVER, PORT);


        DataOutputStream out =
                new DataOutputStream(
                        s.getOutputStream());


        FileInputStream fis =
                new FileInputStream(file);


        out.writeUTF("UPLOAD");

        out.writeUTF(file.getName());

        out.writeInt(
                (int) file.length());


        int data;


        while ((data = fis.read()) != -1) {

            byte plain =
                    (byte)data;


            byte cipher =
                    encrypt(plain);


            out.write(cipher);
        }


        fis.close();

        s.close();


        System.out.println(
                fileName +
                " uploaded successfully.");
    }


    // DOWNLOAD FILE
    static void downloadFile(String fileName)
            throws Exception {

        Socket s =
                new Socket(SERVER, PORT);


        DataInputStream in =
                new DataInputStream(
                        s.getInputStream());

        DataOutputStream out =
                new DataOutputStream(
                        s.getOutputStream());


        out.writeUTF("DOWNLOAD");

        out.writeUTF(fileName);


        int size =
                in.readInt();


        if (size == -1) {

            System.out.println(
                    "File not found.");

            s.close();

            return;
        }


        File file =
                new File(
                        CLIENT_FOLDER,
                        fileName);


        FileOutputStream fos =
                new FileOutputStream(file);


        for (int i = 0; i < size; i++) {

            byte cipher =
                    (byte) in.read();


            byte plain =
                    decrypt(cipher);


            fos.write(plain);
        }


        fos.close();

        s.close();


        System.out.println(
                fileName +
                " downloaded successfully.");
    }


    public static void main(String[] args)
            throws Exception {


        File folder =
                new File(CLIENT_FOLDER);


        if (!folder.exists()) {

            folder.mkdir();
        }


        BufferedReader key =
                new BufferedReader(
                        new InputStreamReader(
                                System.in));


        while (true) {

            System.out.println(
                    "\n===== FILE TRANSFER =====");

            System.out.println(
                    "1. List Files");

            System.out.println(
                    "2. Upload File");

            System.out.println(
                    "3. Download File");

            System.out.println(
                    "4. Exit");


            System.out.print(
                    "Enter choice: ");


            String choice =
                    key.readLine();


            switch (choice) {

                case "1":

                    listFiles();

                    break;


                case "2":

                    System.out.print(
                            "Enter file name: ");

                    String upload =
                            key.readLine();

                    uploadFile(upload);

                    break;


                case "3":

                    System.out.print(
                            "Enter file name: ");

                    String download =
                            key.readLine();

                    downloadFile(download);

                    break;


                case "4":

                    System.out.println(
                            "Client closed.");

                    return;


                default:

                    System.out.println(
                            "Invalid choice.");
            }
        }
    }
}
