package com.tencent.qcloud.cosxml.cssg;

import com.tencent.cos.xml.*;
import com.tencent.cos.xml.common.*;
import com.tencent.cos.xml.exception.*;
import com.tencent.cos.xml.listener.*;
import com.tencent.cos.xml.model.*;
import com.tencent.cos.xml.model.object.*;
import com.tencent.cos.xml.model.bucket.*;
import com.tencent.cos.xml.model.tag.*;
import com.tencent.cos.xml.transfer.*;
import com.tencent.qcloud.core.auth.*;
import com.tencent.qcloud.core.common.*;
import com.tencent.qcloud.core.http.*;
import com.tencent.cos.xml.model.service.*;


import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class PutObjectSSE {

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
     * 使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
     */
    private void putObjectSse() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        //.cssg-snippet-body-start:[put-object-sse]
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);
        // 设置使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
        putObjectRequest.setCOSServerSideEncryption();

        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(putObjectRequest, uploadId);
        //.cssg-snippet-body-end
    }

    /**
     * 使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
     */
    private void putObjectSseC() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        //.cssg-snippet-body-start:[put-object-sse-c]
        // 服务端加密密钥
        String customKey = "服务端加密密钥";
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);
        // 设置使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
        try {
            putObjectRequest.setCOSServerSideEncryptionWithCustomerKey(customKey);
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }

        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(putObjectRequest, uploadId);
        //.cssg-snippet-body-end
    }

    /**
     * 使用 KMS 托管加密密钥的服务端加密（SSE-KMS）保护数据
     */
    private void putObjectSseKms() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        //.cssg-snippet-body-start:[put-object-sse-kms]
        // 服务端加密密钥
        String customKey = "用户主密钥 CMK";
        String encryptContext = "加密上下文";
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);

        // 设置使用客户提供的用户主密钥的服务端加密 （SSE-KMS）保护数据
        try {
            putObjectRequest.setCOSServerSideEncryptionWithKMS(customKey, encryptContext);
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }
        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(putObjectRequest, uploadId);
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
    public void testPutObjectSSE() {
        initService();

        // 使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
        putObjectSse();
        
        // 使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
        putObjectSseC();

        // 使用 KMS 托管加密密钥的服务端加密（SSE-KMS）保护数据
        putObjectSseKms();
        
        
        // .cssg-methods-pragma
    }
}
