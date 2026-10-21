import java.net.*;

public class DHCPClient {

    private static final int SERVER_PORT = 4900;

    private static final String SERVER_IP =
            "127.0.0.1";


    public static void main(String[] args) {

        try (DatagramSocket socket =
                     new DatagramSocket()) {

            socket.setSoTimeout(5000);


            InetAddress serverAddress =
                    InetAddress.getByName(
                            SERVER_IP);


            // Send DHCP request
            byte[] requestData =
                    createDHCPRequest(
                            "00:11:22:33:44:55");


            DatagramPacket requestPacket =
                    new DatagramPacket(
                            requestData,
                            requestData.length,
                            serverAddress,
                            SERVER_PORT);


            socket.send(requestPacket);


            System.out.println(
                    "DHCP Request sent.");


            // Receive response
            byte[] receiveData =
                    new byte[1024];


            DatagramPacket receivePacket =
                    new DatagramPacket(
                            receiveData,
                            receiveData.length);


            socket.receive(receivePacket);


            String response =
                    new String(
                            receivePacket.getData(),
                            0,
                            receivePacket.getLength());


            System.out.println(
                    "Received DHCP Response: "
                    + response);


        } catch (SocketTimeoutException e) {

            System.out.println(
                    "No response from server in 5 seconds");

        } catch (Exception e) {

            e.printStackTrace();
        }
    }


    private static byte[] createDHCPRequest(
            String macAddress) {

        String request =
                "DHCP Request with MAC: "
                + macAddress;

        return request.getBytes();
    }
}
