package com.tencent.qcloud.cosxml.cssg;

import com.tencent.cos.xml.*;
import com.tencent.cos.xml.common.*;
import com.tencent.cos.xml.exception.*;
import com.tencent.cos.xml.listener.*;
import com.tencent.cos.xml.model.*;
import com.tencent.cos.xml.model.object.*;
import com.tencent.cos.xml.transfer.*;
import com.tencent.qcloud.core.auth.*;
import com.tencent.qcloud.core.common.*;

import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class ObjectTagging {

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
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey,
                    sessionToken, startTime, expiredTime);
        }
    }

    private void putUploadObjectTagging() {

        //.cssg-snippet-body-start:[put-upload-object-tagging]
        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        //初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject")
                .toString(); //本地文件的绝对路径
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);
        try {
            // 设置对象标签，标签集合中的 Key 和 Value 必须先进行 URL 编码
            putObjectRequest.setRequestHeaders("x-cos-tagging", "Key1=Value&Key2=Value2", false);
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }
        // 若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;
        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                srcPath, uploadId);
        //设置返回结果回调
        cosxmlUploadTask.setCosXmlResultListener(new CosXmlResultListener() {

            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                COSXMLUploadTask.COSXMLUploadTaskResult cOSXMLUploadTaskResult =
                        (COSXMLUploadTask.COSXMLUploadTaskResult) result;
            }
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
     * 设置对象标签
     */
    private void putObjectTagging() {
        //.cssg-snippet-body-start:[put-object-tagging]
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        PutObjectTaggingRequest putObjectTaggingRequest = new PutObjectTaggingRequest(bucket, cosPath);
        putObjectTaggingRequest.addTag("key", "value");
        try {
            PutObjectTaggingResult putObjectTaggingResult = cosXmlService.putObjectTagging(putObjectTaggingRequest);
        } catch (CosXmlClientException clientException) {
            clientException.printStackTrace();
        } catch (CosXmlServiceException serviceException) {
            serviceException.printStackTrace();
        }
        //.cssg-snippet-body-end
    }

    /**
     * 获取对象标签
     */
    private void getObjectTagging() {
        //.cssg-snippet-body-start:[get-object-tagging]
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        GetObjectTaggingRequest getObjectTaggingRequest = new GetObjectTaggingRequest(bucket, cosPath);
        try {
            GetObjectTaggingResult getObjectTaggingResult = cosXmlService.getObjectTagging(getObjectTaggingRequest);
        } catch (CosXmlClientException clientException) {
            clientException.printStackTrace();
        } catch (CosXmlServiceException serviceException) {
            serviceException.printStackTrace();
        }
        //.cssg-snippet-body-end
    }

    /**
     * 删除对象标签
     */
    private void deleteObjectTagging() {
        //.cssg-snippet-body-start:[delete-object-tagging]
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        DeleteObjectTaggingRequest deleteObjectTaggingRequest = new DeleteObjectTaggingRequest(bucket, cosPath);
        try {
            DeleteObjectTaggingResult deleteObjectTaggingResult = cosXmlService.deleteObjectTagging(deleteObjectTaggingRequest);
        } catch (CosXmlClientException clientException) {
            clientException.printStackTrace();
        } catch (CosXmlServiceException serviceException) {
            serviceException.printStackTrace();
        }
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
        cosXmlService = new CosXmlService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testObjectTagging() {
        initService();

        // 设置对象标签
        putObjectTagging();

        // 获取对象标签
        getObjectTagging();

        // 删除对象标签
        deleteObjectTagging();
        // .cssg-methods-pragma

    }
}
