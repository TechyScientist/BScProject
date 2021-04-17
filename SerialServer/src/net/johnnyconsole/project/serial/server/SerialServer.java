package net.johnnyconsole.project.serial.server;

import jssc.SerialPort;
import jssc.SerialPortException;

import java.util.Scanner;

public class SerialServer {

    private static byte[][] blocks;

    public static void main(String[] args) {
        blocks = new byte[10][256];

        System.out.println("Creating Random Blocks...");
        for (int i = 0; i < blocks.length; i++) {
            for (int j = 0; j < blocks[i].length; j++) {
                blocks[i][j] = (byte)(Math.random() * 256);
            }
        }
        System.out.println("Random Blocks Created");
        int currBlock = 0;
        boolean started = false;
        Scanner scanner = new Scanner(System.in);
        System.out.print("Serial Port: ");
        String portName = scanner.nextLine();
        SerialPort port = new SerialPort(portName);
        try {
            if(port.isOpened()) return;
            System.out.println("Opening port " + portName + " on 9600 baud with 8 data bits and 1 stop bit...");
            if(port.openPort() && port.setParams(9600, 8, 1, 0)) {
                System.out.println("Port Opened, Waiting for command...");
                while (true) {
                    char command = (char) port.readBytes(1)[0];
                    System.out.println("Command Received: " + Character.toUpperCase(command));
                    switch (command) {
                        case 'S':
                            if (started) break;
                            else {
                                started = true;
                                port.writeBytes(blocks[currBlock]);
                            }
                            break;
                        case 'C':
                            if (!started) break;
                            else port.writeInt(checksum(currBlock));
                            break;
                        case 'N':
                            if (!started) {
                                started = true;
                                port.writeBytes(blocks[currBlock]);
                            } else port.writeBytes(blocks[(++currBlock) % 256]);
                            break;
                        case 'R':
                            if (!started) started = true;
                            port.writeBytes(blocks[currBlock]);
                            break;
                        case 'X':
                            started = false;
                            port.closePort();
                            System.exit(0);
                    }
                }
            }
        } catch (SerialPortException ex) {
            System.err.println(ex);
        }
    }

    private static int checksum(int blockNum) {
        byte[] block = blocks[blockNum];
        int sum = 0;
        for (byte b : block) {
            sum += b;
        }
        return sum;
    }

}
