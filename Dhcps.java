import java.net.*;
import java.util.*;

public class DHCPServer {

    private static final int SERVER_PORT = 4900;


    private static List<String> availableIpAddresses =
            new ArrayList<>();


    private static Map<String, String> ipAllocations =
            new HashMap<>();


    public static void main(String[] args) {

        initializeIpAddresses();


        try (DatagramSocket socket =
                     new DatagramSocket(
                             SERVER_PORT)) {


            System.out.println(
                    "DHCP Server started on port "
                    + SERVER_PORT);


            while (true) {

                // Receive request
                byte[] receiveData =
                        new byte[1024];


                DatagramPacket receivePacket =
                        new DatagramPacket(
                                receiveData,
                                receiveData.length);


                socket.receive(receivePacket);


                // Convert request to String
                String request =
                        new String(
                                receivePacket.getData(),
                                0,
                                receivePacket.getLength());


                // Extract MAC
                String macAddress =
                        extractMacAddress(
                                request);


                // Allocate IP
                String allocatedIp =
                        allocateIpAddress(
                                macAddress);


                // Create response
                byte[] responseData =
                        createDHCPResponse(
                                macAddress,
                                allocatedIp);


                // Send response
                DatagramPacket responsePacket =
                        new DatagramPacket(
                                responseData,
                                responseData.length,
                                receivePacket.getAddress(),
                                receivePacket.getPort());


                socket.send(responsePacket);


                System.out.println(
                        "Allocated "
                        + allocatedIp
                        + " to "
                        + macAddress);
            }


        } catch (Exception e) {

            e.printStackTrace();
        }
    }


    // Create available IP addresses
    private static void initializeIpAddresses() {

        for (int i = 2; i <= 254; i++) {

            String ip =
                    "192.168.1." + i;

            availableIpAddresses.add(ip);
        }
    }


    // Extract MAC address
    private static String extractMacAddress(
            String request) {

        if (request.contains("MAC:")) {

            return request.substring(
                    request.indexOf("MAC:") + 4)
                    .trim();
        }

        return request.trim();
    }


    // Allocate IP address
    private static String allocateIpAddress(
            String macAddress) {

        // Return same IP if MAC already exists
        if (ipAllocations.containsKey(
                macAddress)) {

            return ipAllocations.get(
                    macAddress);
        }


        // No IP available
        if (availableIpAddresses.isEmpty()) {

            return "No available IP addresses";
        }


        // Take first available IP
        String allocatedIp =
                availableIpAddresses.remove(0);


        // Store in memory
        ipAllocations.put(
                macAddress,
                allocatedIp);


        return allocatedIp;
    }


    // Create response
    private static byte[] createDHCPResponse(
            String macAddress,
            String allocatedIp) {

        String response =
                "Allocated IP: "
                + allocatedIp
                + " for MAC: "
                + macAddress;


        return response.getBytes();
    }
}
