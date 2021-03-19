package com.tencent.qcloud.cosxml.cssg;

import com.tencent.cos.xml.*;
import com.tencent.cos.xml.common.*;
import com.tencent.cos.xml.exception.*;
import com.tencent.cos.xml.listener.*;
import com.tencent.cos.xml.model.*;
import com.tencent.cos.xml.model.object.*;
import com.tencent.cos.xml.model.bucket.*;
import com.tencent.cos.xml.model.tag.*;
import com.tencent.cos.xml.model.tag.pic.PicOperationRule;
import com.tencent.cos.xml.model.tag.pic.PicOperations;
import com.tencent.cos.xml.transfer.*;
import com.tencent.qcloud.core.auth.*;
import com.tencent.qcloud.core.common.*;
import com.tencent.qcloud.core.http.*;
import com.tencent.cos.xml.model.service.*;
import com.tencent.qcloud.cosxml.cssg.BuildConfig;

import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class PictureOperation {

    private Context context;
    private CosXmlService cosXmlService;

    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {
        
        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {
    
            // 首先从您的临时密钥服务器获取包含了密钥信息的响应
    
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
     * 上传时图片处理
     */
    private void uploadWithPicOperation() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; // 对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject.jpg")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        //.cssg-snippet-body-start:[upload-with-pic-operation]
        List<PicOperationRule> rules = new LinkedList<>();
        // 添加一条将图片转化为 png 格式的 rule，处理后的图片在存储桶中的位置标识符为
        // examplepngobject
        rules.add(new PicOperationRule("examplepngobject", "imageView2/format/png"));
        PicOperations picOperations = new PicOperations(true, rules);

        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);
        putObjectRequest.setPicOperations(picOperations);

        // 上传成功后，您将会得到 2 张图片，分别是原始图片和处理后图片
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(putObjectRequest, uploadId);
        //.cssg-snippet-body-end
    }

    /**
     * 对云上数据进行图片处理
     */
    private void processWithPicOperation() {
        //.cssg-snippet-body-start:[process-with-pic-operation]
        
        //.cssg-snippet-body-end
    }

    /**
     * 上传时添加盲水印
     */
    private void putObjectWithWatermark() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; // 对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject.jpg")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        //.cssg-snippet-body-start:[put-object-with-watermark]
        List<PicOperationRule> rules = new LinkedList<>();
        // 添加一条将盲水印 rule，处理后的图片在存储桶中的位置标识符为
        // examplewatermarkobject
        rules.add(new PicOperationRule("examplewatermarkobject",
                "watermark/3/type/1/image/aHR0cDovL2V4YW1wbGVzLTEyNTEwMDAw"));
        PicOperations picOperations = new PicOperations(true, rules);

        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);
        putObjectRequest.setPicOperations(picOperations);

        // 上传成功后，您将会得到 2 张图片，分别是原始图片和处理后图片
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(putObjectRequest, uploadId);
        //.cssg-snippet-body-end
    }

    /**
     * 下载时添加盲水印
     */
    private void downloadObjectWithWatermark() {

        // 高级下载接口支持断点续传，所以会在下载前先发起 HEAD 请求获取文件信息。
        // 如果您使用的是临时密钥或者使用子账号访问，请确保权限列表中包含 HeadObject 的权限。

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        //初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        //本地目录路径
        String savePathDir = context.getExternalCacheDir().toString();
        //本地保存的文件名，若不填（null），则与 COS 上的文件名一样
        String savedFileName = "exampleobject";

        // application context
        Context applicationContext = context.getApplicationContext();

        //.cssg-snippet-body-start:[download-object-with-watermark]
        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, cosPath, savePathDir, savedFileName);
        Map<String, String> params = new HashMap<>();
        // 添加文字盲水印
        params.put("watermark/3/type/3/text/dGVuY2VudCBjbG91ZA==", null);
        getObjectRequest.setQueryParameters(params);

        COSXMLDownloadTask cosxmlDownloadTask =
                transferManager.download(applicationContext, getObjectRequest);

        //.cssg-snippet-body-end
    }

    /**
     * 图片审核
     */
    private void sensitiveContentRecognition() {
        // TODO: 2020/8/14
        //.cssg-snippet-body-start:[sensitive-content-recognition]
        //.cssg-snippet-body-end
    }


    // .cssg-methods-pragma

    private void initService() {
        String region = "ap-guangzhou";
        
        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();
        
        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        cosXmlService = new CosXmlService(context, serviceConfig, new ServerCredentialProvider());
    }

    @Test
    public void testPictureOperation() {
        initService();

        // 上传时图片处理
        uploadWithPicOperation();

        // 对云上数据进行图片处理
        processWithPicOperation();

        // 上传时添加盲水印
        putObjectWithWatermark();
        
        // 下载时添加盲水印
        downloadObjectWithWatermark();
        
        // 图片审核
        sensitiveContentRecognition();
        
        
        // .cssg-methods-pragma
    }
}
