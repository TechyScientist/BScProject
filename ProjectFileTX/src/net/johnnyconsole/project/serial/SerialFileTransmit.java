package net.johnnyconsole.project.serial;

import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.geometry.HPos;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.layout.GridPane;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import jssc.SerialPort;
import jssc.SerialPortException;
import jssc.SerialPortList;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

/**
 * @author Johnny Console
 * Course: COSC 4086 - Fourth Year Project
 * SerialFileTransmit: Transmit file bytes
 * over serial connection to load a new
 * sound sample into project memory
 */
public class SerialFileTransmit extends Application {

    private String portName;
    private final byte[] block = new byte[256];
    private int place = 0;
    private File file;
    private Button selectFile, beginTX;
    private ComboBox<String> ports;
    private Label status;
    @Override
    public void start(Stage ps) {
        //Root pane setup
        GridPane pane = new GridPane();
        pane.setPadding(new Insets(20));
        pane.setHgap(20);
        pane.setVgap(20);

        //UI object definition
        String[] list = SerialPortList.getPortNames();
        ports = new ComboBox<>(FXCollections.observableArrayList(list));
        selectFile = new Button("Select File...");
        beginTX = new Button("Begin Transmission");
        status = new Label("Select A File");

        //Attach properties to UI elements
        ports.getSelectionModel().select(0);
        ports.setMaxWidth(Double.MAX_VALUE);
        selectFile.setMaxWidth(Double.MAX_VALUE);
        beginTX.setDisable(true);
        beginTX.setMaxWidth(Double.MAX_VALUE);
        GridPane.setHalignment(status, HPos.CENTER);

        //Attach actions to UI elements
        selectFile.setOnAction(e -> selectFile(ps));
        beginTX.setOnAction(e -> beginTX(ps));

        //Add UI elements to root pane
        pane.add(status, 0, 0, 2, 1);
        pane.addRow(1, new Label("Select Serial Port:"), ports);
        pane.add(selectFile, 0, 2, 2, 1);
        pane.add(beginTX, 0, 3, 2, 1);

        //Stage and scene setup
        Scene scene = new Scene(pane);
        ps.setScene(scene);
        ps.setTitle("Transmit");
        ps.show();
    }

    private void selectFile(Stage ps) {
        //Get the File
        FileChooser chooser = new FileChooser();
        chooser.setTitle("Choose File to Transmit");
        chooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("Binary Sound Samples (*.raw)", "*.raw"));
        file = chooser.showOpenDialog(ps);
        if(file != null) {
            //If a file is selected, disable the select button ad enable the transmit button
            if(file.length() % 256 == 0) {
                beginTX.setDisable(false);
                selectFile.setDisable(true);
                selectFile.setText(file.getName());
                status.setText("File Selected - Ready");
            }
            else {
                status.setText("Invalid File - Length Invalid");
                System.out.println(file.length());
            }
        }
    }

    private void beginTX(Stage ps) {
        //Get the port information
        portName = ports.getSelectionModel().getSelectedItem();
        ports.setDisable(true);
        beginTX.setText("Transmitting Data...");
        beginTX.setDisable(true);
        //Start acting like a serial server
        serialServer(ps);
    }

    private void serialServer(Stage ps) {
        try {
            byte[] fileBytes = Files.readAllBytes(file.toPath());
            SerialPort port = new SerialPort(portName);
            if(port.openPort() && port.setParams(115200, 8, 1, 0)) {
                port.setFlowControlMode(SerialPort.FLOWCONTROL_NONE);
                System.arraycopy(fileBytes, 0, block, 0, block.length);
                port.writeBytes(block);
                System.out.println("Waiting...");
                char command = (char)(port.readBytes(1)[0]);
                System.out.println("Command Received: " + command);
                while (command != 'X') {
                    switch(command) {
                        case 'C':
                            int check = 0;
                            for (int i = 0;i < block.length; i++) {
                                if (i % 2 == 0) {
                                    block[i] = (byte) (block[i] ^ 0x80);
                                }
                                check += (block[i] >= 0 ? block[i] : 256 + block[i]);
                                check %= 256;
                            }
                            port.writeByte((byte) (check % 256));
                            command = (char)(port.readBytes(1)[0]);
                            System.out.println("Command Received in C: " + command);

                            break;
                        case 'N':
                            place += 256;
                            if (place == file.length()) {
                                System.out.println("End Of File");
                                command = 'X';
                                break;
                            } else {
                                System.arraycopy(fileBytes, place, block, 0, block.length);
                            }
                        case 'R':
                            System.out.println("Transmitting Block " + ((place / 256) + 1));
                            port.writeBytes(block);
                            command = (char)(port.readBytes(1)[0]);
                            System.out.println("Command Received in R/N: " + command);
                    }
                }
                ps.close();
            }
        } catch(SerialPortException | IOException ex) {
            System.err.println(ex.getMessage());
        }
    }
}
