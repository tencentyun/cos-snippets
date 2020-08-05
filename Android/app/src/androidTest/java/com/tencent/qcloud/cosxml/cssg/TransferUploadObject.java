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
import com.tencent.qcloud.cosxml.cssg.BuildConfig;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class TransferUploadObject {

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
     * 高级接口上传对象
     */
    private void transferUploadFile() {
        //.cssg-snippet-body-start:[transfer-upload-file]
        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                srcPath, uploadId);

        //设置上传进度回调
        cosxmlUploadTask.setCosXmlProgressListener(new CosXmlProgressListener() {
            @Override
            public void onProgress(long complete, long target) {
                // todo Do something to update progress...
            }
        });
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
        //设置任务状态回调, 可以查看任务过程
        cosxmlUploadTask.setTransferStateListener(new TransferStateListener() {
            @Override
            public void onStateChanged(TransferState state) {
                // todo notify transfer state
            }
        });
        //.cssg-snippet-body-end
    }

    /**
     * 高级接口上传二进制数据
     */
    private void transferUploadBytes() {
        //.cssg-snippet-body-start:[transfer-upload-bytes]
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键

        // 上传字节数组
        byte[] bytes = "this is a test".getBytes(Charset.forName("UTF-8"));
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                bytes);

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
     * 高级接口流式上传
     */
    private void transferUploadStream() {
        //.cssg-snippet-body-start:[transfer-upload-stream]
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键

        // 流式上传
        InputStream inputStream =
                new ByteArrayInputStream("this is a test".getBytes(Charset.forName(
                        "UTF-8")));
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                inputStream);

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


    private void transferUploadUri() {
        //.cssg-snippet-body-start:[transfer-upload-uri]
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键

        // 文件的 Uri
        Uri uri = Uri.parse("exampleObject");
        // 若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                uri, uploadId);

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
     * 上传暂停、续传与取消
     */
    private void transferUploadInteract() {

        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = new File(context.getCacheDir(), "exampleobject")
                .toString(); //本地文件的绝对路径
        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;

        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                srcPath, uploadId);

        //.cssg-snippet-body-start:[transfer-upload-pause]
        // 如果上传过程中，已经发起了最后的 Complete Multipart Upload 请求，那么取消会失败
        boolean pauseSuccess = cosxmlUploadTask.pauseSafely();
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-upload-resume]
        // 如果取消成功，可以恢复上传
        if (pauseSuccess) {
            cosxmlUploadTask.resume();
        }
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-upload-cancel]
        cosxmlUploadTask.cancel();
        //.cssg-snippet-body-end
    }

    /**
     * 批量上传
     */
    private void transferBatchUploadObjects() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键

        //.cssg-snippet-body-start:[transfer-batch-upload-objects]
        //本地文件的绝对路径
        File[] files = new File(context.getCacheDir(), "exampleDirectory").listFiles();

        // 开始批量上传
        for (File file : files) {
            //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
            String uploadId = null;

            // 上传文件
            COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                    file.getAbsolutePath(), uploadId);

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
        cosXmlService = new CosXmlService(context, serviceConfig, new ServerCredentialProvider());
    }

    @Test
    public void testTransferUploadObject() {
        initService();

        // 高级接口上传对象
        transferUploadFile();
        
        // 高级接口上传二进制数据
        transferUploadBytes();
        
        // 高级接口流式上传
        transferUploadStream();

        // 高级接口 URI 上传
        transferUploadUri();
        
        // 上传暂停、续传与取消
        transferUploadInteract();
        
        // 批量上传
        transferBatchUploadObjects();
        
        
        // .cssg-methods-pragma
    }
}
