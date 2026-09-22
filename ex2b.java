import java.io.*;
import java.net.*;

public class SecureServer {

    static final int PORT = 4567;

    static final String SERVER_FOLDER = "ServerFiles";


    public static void main(String[] args) {

        File folder = new File(SERVER_FOLDER);

        if (!folder.exists()) {
            folder.mkdir();
        }


        try (ServerSocket ss = new ServerSocket(PORT)) {

            System.out.println("Server started...");
            System.out.println("Waiting for client...");


            while (true) {

                Socket s = ss.accept();

                System.out.println("Client connected!");

                new Thread(new ClientHandler(s)).start();
            }

        } catch (Exception e) {

            e.printStackTrace();
        }
    }


    static class ClientHandler implements Runnable {

        Socket s;


        ClientHandler(Socket s) {
            this.s = s;
        }


        public void run() {

            try {

                DataInputStream in =
                        new DataInputStream(
                                s.getInputStream());

                DataOutputStream out =
                        new DataOutputStream(
                                s.getOutputStream());


                String command = in.readUTF();


                switch (command) {

                    case "LIST":

                        sendFileList(out);

                        break;


                    case "UPLOAD":

                        receiveFile(in);

                        break;


                    case "DOWNLOAD":

                        sendFile(in, out);

                        break;


                    default:

                        System.out.println(
                                "Unknown command");
                }


                s.close();

            } catch (Exception e) {

                System.out.println(
                        "Connection error");
            }
        }


        // SEND FILE LIST
        void sendFileList(DataOutputStream out)
                throws IOException {

            File folder =
                    new File(SERVER_FOLDER);

            File[] files =
                    folder.listFiles(File::isFile);


            if (files == null) {

                out.writeInt(0);

                return;
            }


            out.writeInt(files.length);


            for (File file : files) {

                out.writeUTF(file.getName());
            }


            System.out.println(
                    "File list sent.");
        }


        // RECEIVE UPLOADED FILE
        void receiveFile(DataInputStream in)
                throws IOException {

            String fileName =
                    in.readUTF();

            int fileSize =
                    in.readInt();


            File file =
                    new File(
                            SERVER_FOLDER,
                            fileName);


            FileOutputStream fos =
                    new FileOutputStream(file);


            byte[] buffer =
                    new byte[1024];


            int total = 0;


            while (total < fileSize) {

                int bytesRead =
                        in.read(
                                buffer,
                                0,
                                Math.min(
                                        buffer.length,
                                        fileSize - total));


                if (bytesRead == -1)
                    break;


                fos.write(
                        buffer,
                        0,
                        bytesRead);


                total += bytesRead;
            }


            fos.close();


            System.out.println(
                    fileName +
                    " uploaded successfully.");
        }


        // SEND FILE TO CLIENT
        void sendFile(
                DataInputStream in,
                DataOutputStream out)
                throws IOException {

            String fileName =
                    in.readUTF();


            File file =
                    new File(
                            SERVER_FOLDER,
                            fileName);


            if (!file.exists()) {

                out.writeInt(-1);

                System.out.println(
                        "File not found.");

                return;
            }


            out.writeInt(
                    (int) file.length());


            FileInputStream fis =
                    new FileInputStream(file);


            int data;


            while ((data = fis.read()) != -1) {

                out.write(data);
            }


            fis.close();


            System.out.println(
                    fileName +
                    " sent successfully.");
        }
    }
}
