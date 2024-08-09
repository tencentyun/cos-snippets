package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.os.Environment;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.model.PresignedUrlRequest;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;
import com.tencent.qcloud.core.http.RequestBodySerializer;

import org.junit.Test;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class ObjectPresignUrl {

    private Context context;
    private CosXmlService cosXmlService;

    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {

        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {

            // 首先从您的临时密钥服务器获取包含了密钥信息的响应
			// 临时密钥生成和使用指引参见https://cloud.tencent.com/document/product/436/14048

            // 然后解析响应，获取密钥信息
            String tmpSecretId = "临时密钥 secretId";
            String tmpSecretKey = "临时密钥 secretKey";
            String sessionToken = "临时密钥 TOKEN";
            long expiredTime = 1556183496L;//临时密钥有效截止时间戳，单位是秒

            /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
            // 返回服务器时间作为签名的起始时间
            long startTime = 1556182000L; //临时密钥有效起始时间，单位是秒

            // 最后返回临时密钥信息对象
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey,
                    sessionToken, startTime, expiredTime);
        }
    }

    /**
     * 获取预签名下载链接
     */
    private void getPresignDownloadUrl() {
        //.cssg-snippet-body-start:[get-presign-download-url]
        try {
            String bucket = "examplebucket-1250000000"; //存储桶名称
            String cosPath = "exampleobject"; //即对象在存储桶中的位置标识符。
            String method = "GET"; //请求 HTTP 方法.
            PresignedUrlRequest presignedUrlRequest = new PresignedUrlRequest(bucket
                    , cosPath);
            presignedUrlRequest.setRequestMethod(method);

            // 设置签名有效期为 60s，注意这里是签名有效期，您需要自行保证密钥有效期
            presignedUrlRequest.setSignKeyTime(60);
            // 设置不签名 Host
            presignedUrlRequest.addNoSignHeader("Host");

            // 获取到预签名下载链接
            final String urlWithSign = cosXmlService.getPresignedURL(presignedUrlRequest);
            // 开始下载
            new Thread(new Runnable() {
                @Override
                public void run() {
                    String localPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + "/wechat.png";
                    downloadFile(urlWithSign, localPath);
                }
            }).start();
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }

        //.cssg-snippet-body-end
    }

    /**
     * 获取预签名上传链接
     */
    private void getPresignUploadUrl() {
        //.cssg-snippet-body-start:[get-presign-upload-url]
        try {
            String bucket = "examplebucket-1250000000"; //存储桶名称
            String cosPath = "exampleobject"; //即对象在存储桶中的位置标识符。
            String method = "PUT"; //请求 HTTP 方法
            // 本地文件路径
            final String localPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath() + "/wechat.png";
            PresignedUrlRequest presignedUrlRequest = new PresignedUrlRequest(bucket
                    , cosPath) {
                @Override
                public RequestBodySerializer getRequestBody()
                        throws CosXmlClientException {
                    //用于计算 put 等需要带上 body 的请求的签名 URL
                    return RequestBodySerializer.file(null, new File(localPath));
                }
            };
            presignedUrlRequest.setRequestMethod(method);
            // 设置签名有效期为 60s，注意这里是签名有效期，您需要自行保证密钥有效期
            presignedUrlRequest.setSignKeyTime(60);
            // 设置不签名 Host
            presignedUrlRequest.addNoSignHeader("Host");
            final String urlWithSign = cosXmlService.getPresignedURL(presignedUrlRequest);
            // 开始上传
            new Thread(new Runnable() {
                @Override
                public void run() {
                    uploadFile(urlWithSign, localPath);
                }
            }).start();
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }

        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    private void initService() {
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-guangzhou";

        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();

        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        cosXmlService = new CosXmlService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testObjectPresignUrl() {
        initService();

        // 获取预签名下载链接
        getPresignDownloadUrl();

        // 获取预签名上传链接
        getPresignUploadUrl();
        // .cssg-methods-pragma

    }

    public void downloadFile(String fileUrl, String localPath) {
        int retryCount = 0;
        boolean success = false;
        while (!success && retryCount < 3) {
            HttpURLConnection connection = null;
            InputStream input = null;
            FileOutputStream output = null;
            try {
                URL url = new URL(fileUrl);
                connection = (HttpURLConnection) url.openConnection();
                connection.connect();
                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    if (connection.getResponseCode() >= 500) {
                        retryCount++;
                        continue;
                    } else {
                        throw new RuntimeException("Server returned HTTP " + connection.getResponseCode()
                                + " " + connection.getResponseMessage());
                    }
                }
                input = connection.getInputStream();
                output = new FileOutputStream(localPath);
                byte data[] = new byte[4096];
                int count;
                while ((count = input.read(data)) != -1) {
                    output.write(data, 0, count);
                }
                success = true;
            } catch (Exception e) {
                retryCount++;
            } finally {
                try {
                    if (output != null)
                        output.close();
                    if (input != null)
                        input.close();
                } catch (Exception ignored) {
                }
                if (connection != null)
                    connection.disconnect();
            }
        }
        if (!success) {
            throw new RuntimeException("Failed to download file after 3 attempts");
        }
    }

    public void uploadFile(String targetUrl, String filePath) {
        int retryCount = 0;
        boolean success = false;

        while (!success && retryCount < 3) {
            HttpURLConnection connection = null;
            DataOutputStream outputStream = null;
            FileInputStream fileInputStream = null;

            try {
                fileInputStream = new FileInputStream(filePath);

                URL url = new URL(targetUrl);
                connection = (HttpURLConnection) url.openConnection();

                connection.setDoInput(true);
                connection.setDoOutput(true);
                connection.setUseCaches(false);

                connection.setRequestMethod("POST");

                outputStream = new DataOutputStream(connection.getOutputStream());
                int bytesRead;
                byte[] buffer = new byte[8192];
                while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }

                outputStream.flush();

                if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                    if (connection.getResponseCode() >= 500) {
                        retryCount++;
                        continue;
                    } else {
                        throw new RuntimeException("Server returned HTTP " + connection.getResponseCode()
                                + " " + connection.getResponseMessage());
                    }
                }

                success = true;
            } catch (Exception e) {
                retryCount++;
            } finally {
                try {
                    if (outputStream != null)
                        outputStream.close();
                    if (fileInputStream != null)
                        fileInputStream.close();
                } catch (Exception ignored) {
                }

                if (connection != null)
                    connection.disconnect();
            }
        }

        if (!success) {
            throw new RuntimeException("Failed to upload file after 3 attempts");
        }
    }
}
