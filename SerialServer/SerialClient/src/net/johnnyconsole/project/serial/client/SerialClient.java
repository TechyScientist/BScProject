package net.johnnyconsole.project.serial.client;

import jssc.SerialPort;
import jssc.SerialPortException;

import java.util.Scanner;

public class SerialClient {
    public static void main(String[] args) {
        byte[] block = new byte[256];
        Scanner scanner = new Scanner(System.in);
        System.out.print("Serial Port: ");
        String portName = scanner.nextLine();
        SerialPort port = new SerialPort(portName);
        try {
            if(port.isOpened()) return;
            System.out.println("Opening port " + portName + " on 9600 baud with 8 data bits and 1 stop bit...");
            if(port.openPort() && port.setParams(9600, 8, 1, 0)) {
                System.out.println("Port Opened");
                while (true) {
                    System.out.print(portName + "> ");
                    char command = scanner.nextLine().toUpperCase().charAt(0);
                    port.writeByte((byte) command);
                    if(command == 'S' || command == 'R' || command == 'N') {
                        byte[] response = port.readBytes();
                        System.arraycopy(response, 0, block, 0, 256);
                        System.out.println("Response from " + portName + ": " + printBlock(block));
                    }
                    else if(command == 'C') {
                        int response = port.readIntArray()[0];
                        int checksum = checksum(block);
                        System.out.println("Response from " + portName + ": " + response);
                        System.out.println("Calculated Checksum: " + checksum);
                        if(response != checksum) System.err.println("Checksum Error");
                        else System.out.println("Checksum Verified");
                    } else if (command == 'X') {
                        break;
                    }
                }
            }
        } catch (SerialPortException ex) {
            System.err.println(ex);
        }
    }

    private static int checksum(byte[] block) {
        int sum = 0;
        for (byte b : block) {
            sum += b;
        }
        return sum;
    }

    private static String printBlock(byte[] block) {
        StringBuilder blockStr = new StringBuilder("[");
        for (int i = 0; i < block.length - 1; i++) {
            blockStr.append(block[i]).append(", ");
        }
        blockStr.append(block[block.length - 1]).append("]");
        return blockStr.toString();
    }
}
