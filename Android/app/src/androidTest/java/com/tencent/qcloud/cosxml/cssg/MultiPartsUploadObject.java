package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlProgressListener;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.bucket.ListMultiUploadsRequest;
import com.tencent.cos.xml.model.bucket.ListMultiUploadsResult;
import com.tencent.cos.xml.model.object.CompleteMultiUploadRequest;
import com.tencent.cos.xml.model.object.CompleteMultiUploadResult;
import com.tencent.cos.xml.model.object.InitMultipartUploadRequest;
import com.tencent.cos.xml.model.object.InitMultipartUploadResult;
import com.tencent.cos.xml.model.object.ListPartsRequest;
import com.tencent.cos.xml.model.object.ListPartsResult;
import com.tencent.cos.xml.model.object.UploadPartRequest;
import com.tencent.cos.xml.model.object.UploadPartResult;
import com.tencent.cos.xml.model.tag.ListParts;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.HashMap;
import java.util.Map;

@RunWith(AndroidJUnit4.class)
public class MultiPartsUploadObject {

    private static final int PART_SIZE = 1024 * 1024; // 单个分片大小

    private Context context;
    private CosXmlService cosXmlService;
    private String uploadId;
    private File srcFile;
    private Map<Integer, String> eTags = new HashMap<>();

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

    /**
     * 初始化分片上传
     */
    private void initMultiUpload() {
        //.cssg-snippet-body-start:[init-multi-upload]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键。

        InitMultipartUploadRequest initMultipartUploadRequest =
                new InitMultipartUploadRequest(bucket, cosPath);
        cosXmlService.initMultipartUploadAsync(initMultipartUploadRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                // 分片上传的 uploadId
                uploadId = ((InitMultipartUploadResult) result)
                        .initMultipartUpload.uploadId;
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
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
     * 列出所有未完成的分片上传任务
     */
    private void listMultiUpload() {
        //.cssg-snippet-body-start:[list-multi-upload]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        ListMultiUploadsRequest listMultiUploadsRequest =
                new ListMultiUploadsRequest(bucket);
        cosXmlService.listMultiUploadsAsync(listMultiUploadsRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                ListMultiUploadsResult listMultiUploadsResult =
                        (ListMultiUploadsResult) result;
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
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
     * 上传一个分片
     */
    private void uploadPart(final int partNumber, final int offset) {
        //.cssg-snippet-body-start:[upload-part]
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键
        UploadPartRequest uploadPartRequest = new UploadPartRequest(bucket, cosPath,
                partNumber, srcFile.getPath(), offset, PART_SIZE, uploadId);

        uploadPartRequest.setProgressListener(new CosXmlProgressListener() {
            @Override
            public void onProgress(long progress, long max) {
                // todo Do something to update progress...
            }
        });

        cosXmlService.uploadPartAsync(uploadPartRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                String eTag = ((UploadPartResult) result).eTag;
                eTags.put(partNumber, eTag);
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
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
     * 列出已上传的分片
     */
    private void listParts() {
        //.cssg-snippet-body-start:[list-parts]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键。

        ListPartsRequest listPartsRequest = new ListPartsRequest(bucket, cosPath,
                uploadId);
        cosXmlService.listPartsAsync(listPartsRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                ListParts listParts = ((ListPartsResult) result).listParts;
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
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
     * 完成分片上传任务
     */
    private void completeMultiUpload() {
        //.cssg-snippet-body-start:[complete-multi-upload]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键。

        CompleteMultiUploadRequest completeMultiUploadRequest =
                new CompleteMultiUploadRequest(bucket,
                cosPath, uploadId, eTags);
        cosXmlService.completeMultiUploadAsync(completeMultiUploadRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                CompleteMultiUploadResult completeMultiUploadResult =
                        (CompleteMultiUploadResult) result;
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
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
    // .cssg-methods-pragma

    @Test
    public void testMultiPartsUploadObject() {
        initService();

        // 初始化分片上传
        initMultiUpload();

        // 列出所有未完成的分片上传任务
        listMultiUpload();

        // 创建临时文件
        try {
            srcFile = new File(context.getCacheDir(), "exampleobject");
            if (!srcFile.exists() && srcFile.createNewFile()) {
                RandomAccessFile raf = new RandomAccessFile(srcFile, "rw");
                raf.setLength(3000000);
                raf.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 分片数量
        int partCount = (int) Math.ceil(srcFile.length() / (double) PART_SIZE);
        // 上传分片，下标从1开始
        for (int i = 1; i < partCount + 1; i++) {
            uploadPart(partCount, (partCount - 1) * PART_SIZE);
        }

        // 列出已上传的分片
        listParts();

        // 完成分片上传任务
        completeMultiUpload();
        // .cssg-methods-pragma

    }
}
