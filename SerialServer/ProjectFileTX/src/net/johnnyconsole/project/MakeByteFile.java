package net.johnnyconsole.project;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;
import java.nio.ShortBuffer;
import java.nio.channels.FileChannel;

public class MakeByteFile {

    public static void main(String[] args) {
        try {
            short[] block = new short[128];
            for (int i = 0; i < 128; i++) {
                double f = (1 + Math.sin(2 * Math.PI * (i / 128.0))) * 65535.0 / 2.0;
                int x = (int)f;
                block[i] = (x < 32768 ? (short)x : (short)(x - 65536));
            }
            File file = new File("sine.bin");
            FileChannel out = new FileOutputStream(file).getChannel();
            ByteBuffer buffer = ByteBuffer.allocate(256);
            buffer.order(ByteOrder.BIG_ENDIAN);
            ShortBuffer sBuffer = buffer.asShortBuffer();
            sBuffer.put(block);
            out.write(buffer);
            out.close();
        } catch(IOException ex) {
            System.err.println("File Error");
        }

    }

}
