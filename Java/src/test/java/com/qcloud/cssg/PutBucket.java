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

public class PutBucket {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 创建存储桶
     */
    public void putBucket() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-bucket]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        CreateBucketRequest createBucketRequest = new CreateBucketRequest(bucket);
        // 设置 bucket 的权限为 Private(私有读写), 其他可选有公有读私有写, 公有读写
        createBucketRequest.setCannedAcl(CannedAccessControlList.Private);
        Bucket bucketResult = cosClient.createBucket(createBucketRequest);
        
        //.cssg-snippet-body-end
    }

    /**
     * 创建存储桶并且授予存储桶权限
     */
    public void putBucketAndGrantAcl() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-bucket-and-grant-acl]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        CreateBucketRequest createBucketRequest = new CreateBucketRequest(bucket);
        // 设置 bucket 的权限为 Private(私有读写), 其他可选有公有读私有写, 公有读写
        createBucketRequest.setCannedAcl(CannedAccessControlList.Private);
        try{
            Bucket bucketResult = cosClient.createBucket(createBucketRequest);
        } catch (CosServiceException serverException) {
            serverException.printStackTrace();
        } catch (CosClientException clientException) {
            clientException.printStackTrace();
        }
        
        //.cssg-snippet-body-end
    }

    /**
     * 创建存储桶
     */
    public void putBucketComplete() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-bucket-complete]
        // 存储桶名称，格式为：BucketName-APPID
        String bucketName = "examplebucket-1250000000";
        
        // 以下是向这个存储桶上传一个文件的示例
        String key = "exampleobject";
        File localFile = new File(localFilePath);
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        // 设置存储类型：标准存储（Standard）, 低频存储（Standard_IA）和归档存储（ARCHIVE）。默认是标准存储（Standard）
        putObjectRequest.setStorageClass(StorageClass.Standard_IA);
        
        PutObjectResult putObjectResult = cosClient.putObject(putObjectRequest);
        // putobjectResult 会返回文件的 etag
        String etag = putObjectResult.getETag();
        
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
        PutBucket example = new PutBucket();
        example.initClient();

        // 创建存储桶
        example.putBucket();

        // 创建存储桶并且授予存储桶权限
        example.putBucketAndGrantAcl();

        // 创建存储桶
        example.putBucketComplete();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}