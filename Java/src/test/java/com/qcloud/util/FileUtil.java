package com.qcloud.util;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.ThreadLocalRandom;

public class FileUtil {

    public static void buildTestFile(String fileName, long fileSize) throws IOException {
        BufferedOutputStream bos = null;
        try {
            bos = new BufferedOutputStream(new FileOutputStream(fileName));
            final int buffSize = 1024;
            byte[] tmpBuf = new byte[buffSize];
            long byteWriten = 0;
            while (byteWriten < fileSize) {
                ThreadLocalRandom.current().nextBytes(tmpBuf);
                long maxWriteLen = Math.min(buffSize, fileSize - byteWriten);
                bos.write(tmpBuf, 0, new Long(maxWriteLen).intValue());
                byteWriten += maxWriteLen;
            }
        } finally {
            if (bos != null) {
                try {
                    bos.close();
                } catch (IOException e) {
                }
            }
        }
    }
}
