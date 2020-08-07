package com.qcloud.cssg;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.COSEncryptionClient;
import com.qcloud.cos.ClientConfig;
import com.qcloud.cos.auth.*;
import com.qcloud.cos.exception.*;
import com.qcloud.cos.model.*;
import com.qcloud.cos.internal.crypto.*;
import com.qcloud.cos.region.Region;
import com.qcloud.cos.http.HttpMethodName;
import com.qcloud.cos.utils.DateUtils;
import com.qcloud.cos.transfer.*;
import com.qcloud.cos.model.lifecycle.*;
import com.qcloud.cos.model.inventory.*;
import com.qcloud.cos.model.inventory.InventoryFrequency;

import com.qcloud.util.FileUtil;

import java.io.*;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Date;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.net.URL;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import java.security.KeyPair;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadLocalRandom;

public class MultiPartsUploadObject {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 初始化分片上传
     */
    public void initMultiUpload() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[init-multi-upload]
        // Bucket的命名格式为 BucketName-APPID
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        InitiateMultipartUploadRequest initRequest = new InitiateMultipartUploadRequest(bucketName, key);
        InitiateMultipartUploadResult initResponse = cosClient.initiateMultipartUpload(initRequest);
        uploadId = initResponse.getUploadId();
        
        //.cssg-snippet-body-end
    }

    /**
     * 列出所有未完成的分片上传任务
     */
    public void listMultiUpload() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[list-multi-upload]
        // Bucket的命名格式为 BucketName-APPID ，此处填写的存储桶名称必须为此格式
        String bucketName = "examplebucket-1250000000";
        ListMultipartUploadsRequest listMultipartUploadsRequest = new ListMultipartUploadsRequest(bucketName);
        listMultipartUploadsRequest.setDelimiter("/");
        listMultipartUploadsRequest.setMaxUploads(100);
        listMultipartUploadsRequest.setPrefix("");
        listMultipartUploadsRequest.setEncodingType("url");
        MultipartUploadListing multipartUploadListing = cosClient.listMultipartUploads(listMultipartUploadsRequest);
        
        //.cssg-snippet-body-end
    }

    /**
     * 上传一个分片
     */
    public void uploadPart() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[upload-part]
        // 上传分块, 最多10000个分块, 分块大小支持为1M - 5G。
        // 分块大小设置为4M。如果总计 n 个分块, 则 1 ~ n-1 的分块大小一致，最后一块小于等于前面的分块大小。
        partETags = new ArrayList<PartETag>();
        int partNumber = 1;
        int partSize = 4 * 1024 * 1024;
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        byte data[] = new byte[partSize];
        ByteArrayInputStream partStream = new ByteArrayInputStream(data);
        // partStream 代表 part 数据的输入流, 流长度为 partSize
        UploadPartRequest uploadRequest = new UploadPartRequest().withBucketName(bucketName).
                withUploadId(uploadId).withKey(key).withPartNumber(partNumber).
                withInputStream(partStream).withPartSize(partSize);
        UploadPartResult uploadPartResult = cosClient.uploadPart(uploadRequest);
        // 获取分块的 Etag
        String etag = uploadPartResult.getETag();
        // 获取分块的 CRC64
        String crc64Ecma = uploadPartResult.getCrc64Ecma();
        partETags.add(new PartETag(partNumber, etag));  // partETags 记录所有已上传的 part 的 Etag 信息
        // ... 上传 partNumber 第2个到第 n 个分块
        
        //.cssg-snippet-body-end
    }

    /**
     * 列出已上传的分片
     */
    public void listParts() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[list-parts]
        // ListPart 用于在 complete 分块上传前或者 abort 分块上传前获取 uploadId 对应的已上传的分块信息, 可以用来构造 partEtags
        List<PartETag> partETags = new ArrayList<PartETag>();
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        ListPartsRequest listPartsRequest = new ListPartsRequest(bucketName, key, uploadId);
        PartListing partListing = null;
        do {
            partListing = cosClient.listParts(listPartsRequest);
            for (PartSummary partSummary : partListing.getParts()) {
                partETags.add(new PartETag(partSummary.getPartNumber(), partSummary.getETag()));
            }
            listPartsRequest.setPartNumberMarker(partListing.getNextPartNumberMarker());
        } while (partListing.isTruncated());
        
        //.cssg-snippet-body-end
    }

    /**
     * 完成分片上传任务
     */
    public void completeMultiUpload() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[complete-multi-upload]
        // complete 完成分块上传.
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        CompleteMultipartUploadRequest compRequest = new CompleteMultipartUploadRequest(bucketName, key, uploadId, partETags);
        CompleteMultipartUploadResult result = cosClient.completeMultipartUpload(compRequest);
        
        //.cssg-snippet-body-end
    }

    // .cssg-methods-pragma

    private void initClient() {
        String secretId = "COS_SECRETID";
        String secretKey = "COS_SECRETKEY";
        COSCredentials cred = new BasicCOSCredentials(secretId, secretKey);
        // 2 设置 bucket 的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
        // clientConfig 中包含了设置 region, https(默认 http), 超时, 代理等 set 方法, 使用可参见源码或者常见问题 Java SDK 部分。
        Region region = new Region("COS_REGION");
        ClientConfig clientConfig = new ClientConfig(region);
        // 3 生成 cos 客户端。
        this.cosClient = new COSClient(cred, clientConfig);

        // 高级接口传输类
        // 线程池大小，建议在客户端与 COS 网络充足（例如使用腾讯云的 CVM，同地域上传 COS）的情况下，设置成16或32即可，可较充分的利用网络资源
        // 对于使用公网传输且网络带宽质量不高的情况，建议减小该值，避免因网速过慢，造成请求超时。
        ExecutorService threadPool = Executors.newFixedThreadPool(32);
        // 传入一个 threadpool, 若不传入线程池，默认 TransferManager 中会生成一个单线程的线程池。
        transferManager = new TransferManager(cosClient, threadPool);
        // 设置高级接口的分块上传阈值和分块大小为10MB
        TransferManagerConfiguration transferManagerConfiguration = new TransferManagerConfiguration();
        transferManagerConfiguration.setMultipartUploadThreshold(10 * 1024 * 1024);
        transferManagerConfiguration.setMinimumUploadPartSize(10 * 1024 * 1024);
        transferManager.setConfiguration(transferManagerConfiguration);
    }

    public static void main(String[] args) throws InterruptedException, IOException,        NoSuchAlgorithmException {
        MultiPartsUploadObject example = new MultiPartsUploadObject();
        example.initClient();

        // 初始化分片上传
        example.initMultiUpload();

        // 列出所有未完成的分片上传任务
        example.listMultiUpload();

        // 上传一个分片
        example.uploadPart();

        // 列出已上传的分片
        example.listParts();

        // 完成分片上传任务
        example.completeMultiUpload();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}