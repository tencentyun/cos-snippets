package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CIService;
import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.SensitiveContentRecognitionRequest;
import com.tencent.cos.xml.model.ci.SensitiveContentRecognitionResult;
import com.tencent.cos.xml.model.object.GetObjectRequest;
import com.tencent.cos.xml.model.object.GetObjectResult;
import com.tencent.cos.xml.model.object.PutObjectRequest;
import com.tencent.cos.xml.model.tag.pic.PicOperationRule;
import com.tencent.cos.xml.model.tag.pic.PicOperations;
import com.tencent.cos.xml.transfer.COSXMLDownloadTask;
import com.tencent.cos.xml.transfer.COSXMLUploadTask;
import com.tencent.cos.xml.transfer.TransferConfig;
import com.tencent.cos.xml.transfer.TransferManager;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

import java.io.File;
import java.util.LinkedList;
import java.util.List;

public class PictureOperation {

    private Context context;
    private CosXmlService cosXmlService;
    CIService ciService;

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
     * 上传时图片处理
     */
    private void uploadWithPicOperation() {

        // 初始化 TransferConfig，这里使用默认配置，如果需要定制，请参考 SDK 接口文档
        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
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

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
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

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        //本地目录路径
        String savePathDir = context.getExternalCacheDir().toString();
        //本地保存的文件名，若不填（null），则与 COS 上的文件名一样
        String savedFileName = "exampleobject";

        // application context
        Context applicationContext = context.getApplicationContext();

        //.cssg-snippet-body-start:[download-object-with-watermark]
        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, cosPath, savePathDir, savedFileName);
        // 添加文字盲水印
        getObjectRequest.addQuery("watermark/3/type/3/text/dGVuY2VudCBjbG91ZA==", null);

        COSXMLDownloadTask cosxmlDownloadTask =
                transferManager.download(applicationContext, getObjectRequest);

        //.cssg-snippet-body-end
    }

    /**
     * 图片审核
     */
    private void sensitiveContentRecognition() {
        //.cssg-snippet-body-start:[sensitive-content-recognition]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String key = "exampleobject"; //对象键
        SensitiveContentRecognitionRequest sensitiveContentRecognitionRequest = new SensitiveContentRecognitionRequest(bucket, key);
        // CIService 是 CosXmlService 的子类，初始化方法和 CosXmlService 一致
        ciService.sensitiveContentRecognitionAsync(sensitiveContentRecognitionRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                SensitiveContentRecognitionResult sensitiveContentRecognitionResult = (SensitiveContentRecognitionResult) result;
            }

            @Override
            public void onFail(CosXmlRequest request, CosXmlClientException clientException, CosXmlServiceException serviceException) {
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
     * 下载时进行图片处理
     */
    private void downloadWithPicOperation() {
        //.cssg-snippet-body-start:[download-with-pic-operation]

        //.cssg-snippet-body-end
    }



    private void getObjectThumbnail() {
        //.cssg-snippet-body-start:[get-object-thumbnail]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象位于存储桶中的位置标识符，即对象键
        String savePath = context.getExternalCacheDir().toString(); //本地路径

        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, cosPath,
                savePath);
        getObjectRequest.addQuery("imageMogr2/thumbnail/!50p", null);

        cosXmlService.getObjectAsync(getObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest,
                                  CosXmlResult cosXmlResult) {
                GetObjectResult getObjectResult = (GetObjectResult) cosXmlResult;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        //.cssg-snippet-body-end
    }

    private void getObjectIRadius() {
        //.cssg-snippet-body-start:[get-object-iradius]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象位于存储桶中的位置标识符，即对象键
        String savePath = context.getExternalCacheDir().toString(); //本地路径

        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, cosPath,
                savePath);
        getObjectRequest.addQuery("imageMogr2/iradius/150", null);

        cosXmlService.getObjectAsync(getObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest,
                                  CosXmlResult cosXmlResult) {
                GetObjectResult getObjectResult = (GetObjectResult) cosXmlResult;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        //.cssg-snippet-body-end
    }

    private void getObjectRotate() {
        //.cssg-snippet-body-start:[get-object-rotate]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象位于存储桶中的位置标识符，即对象键
        String savePath = context.getExternalCacheDir().toString(); //本地路径

        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, cosPath,
                savePath);
        getObjectRequest.addQuery("imageMogr2/rotate/90", null);

        cosXmlService.getObjectAsync(getObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest,
                                  CosXmlResult cosXmlResult) {
                GetObjectResult getObjectResult = (GetObjectResult) cosXmlResult;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
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

        // 下载时进行图片处理
        downloadWithPicOperation();
        
        
        
        // .cssg-methods-pragma
    }
}
