package com.tencent.qcloud.cosxml.cssg;

import android.support.annotation.Nullable;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlProgressListener;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.object.GetObjectRequest;
import com.tencent.cos.xml.model.object.PutObjectRequest;
import com.tencent.cos.xml.model.object.PutObjectResult;
import com.tencent.cos.xml.transfer.COSDownloadTask;
import com.tencent.cos.xml.transfer.COSUploadTask;
import com.tencent.cos.xml.transfer.COSXMLUploadTask;
import com.tencent.cos.xml.transfer.TransferConfig;
import com.tencent.cos.xml.transfer.TransferManager;
import com.tencent.cos.xml.transfer.TransferService;
import com.tencent.cos.xml.transfer.TransferState;
import com.tencent.cos.xml.transfer.TransferStateListener;
import com.tencent.cos.xml.utils.DigestUtils;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.charset.Charset;

public class CRC64Verify {

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
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey, sessionToken, startTime, expiredTime);
        }
    }

    /**
     * 高级接口上传对象
     */
    private void uploadVerifyCRC64() {
        //.cssg-snippet-body-start:[upload-verify-crc64]
        // 1. 初始化 TransferService。在相同配置的情况下，您应该复用同一个 TransferService
        TransferConfig transferConfig = new TransferConfig.Builder()
                .build();
        TransferService transferService = new TransferService(cosXmlService, transferConfig);

        // 2. 初始化 PutObjectRequest
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = "examplefilepath"; //本地文件的绝对路径
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket,
                cosPath, srcPath);

        // 3. 调用 upload 方法上传文件
        final COSUploadTask uploadTask = transferService.upload(putObjectRequest);
        uploadTask.setCosXmlResultListener(new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                // 上传成功，可以在这里拿到文件的 CRC64
                String crc64 = result.getHeader("x-cos-hash-crc64ecma");
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest request,
                               CosXmlClientException clientException,
                               CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        
        //.cssg-snippet-body-end
    }

    /**
     * 高级接口上传二进制数据
     */
    private void downloadVerifyCRC64() {
        //.cssg-snippet-body-start:[download-verify-crc64]
        // 1. 初始化 TransferService。在相同配置的情况下，您应该复用同一个 TransferService
        TransferConfig transferConfig = new TransferConfig.Builder()
                .build();
        TransferService transferService = new TransferService(cosXmlService, transferConfig);

        // 2. 初始化 GetObjectRequest
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String savePathDir = context.getCacheDir().toString(); //本地目录路径
        //本地保存的文件名，若不填（null），则与 COS 上的文件名一样
        String savedFileName = "exampleobject";
        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket,
                cosPath, savePathDir, savedFileName);

        // 3. 调用 download 方法下载文件
        final COSDownloadTask downloadTask = transferService.download(getObjectRequest);
        downloadTask.setCosXmlResultListener(new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                // 下载成功，可以在这里拿到 COS 上的文件 CRC64
                String cosCRC64 = result.getHeader("x-cos-hash-crc64ecma");
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest request,
                               CosXmlClientException clientException,
                               CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        
        //.cssg-snippet-body-end
    }

    /**
     * 高级接口上传二进制数据
     */
    private void selfVerifyCRC64() {
        //.cssg-snippet-body-start:[self-verify-crc64]
        // 1. 参考以上上传或者下载请求示例代码获取 COS 上文件的 CRC64 值
        String cosCRC64 = "examplecoscrc64";

        // 2. 计算本地文件的 CRC64
        File localFile = new File("examplefilepath");
        String localCRC64 = DigestUtils.getCRC64String(localFile);

        // 3. 比对 localCRC64 和 cosCRC64 是否一致
        if (localCRC64.equals(cosCRC64)) {
            // CRC64 对比正确
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
        cosXmlService = new CosXmlService(context, serviceConfig, new ServerCredentialProvider());
    }

    @Test
    public void testTransferUploadObject() {
        initService();

        // .cssg-methods-pragma
    }
}
