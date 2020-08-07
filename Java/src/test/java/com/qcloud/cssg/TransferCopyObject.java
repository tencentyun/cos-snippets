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

public class TransferCopyObject {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 高级接口拷贝对象
     */
    public void transferCopyObject() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[transfer-copy-object]
        // 要拷贝的 bucket region, 支持跨地域拷贝
        String secretId = "COS_SECRETID";
        String secretKey = "COS_SECRETKEY";
        COSCredentials srcCredentials = new BasicCOSCredentials(secretId, secretKey);
        Region srcBucketRegion = new Region("COS_REGION");
        // 源 Bucket, 存储桶的命名格式为 BucketName-APPID，此处填写的存储桶名称必须为此格式
        String srcBucketName = "sourcebucket-1250000000";
        // 要拷贝的源文件
        String srcKey = "sourceObject";
        // 目的 Bucket, 存储桶的命名格式为 BucketName-APPID，此处填写的存储桶名称必须为此格式
        String destBucketName = "examplebucket-1250000000";
        // 要拷贝的目的文件
        String destKey = "exampleobject";
        // 生成用于获取源文件信息的 srcCOSClient
        COSClient srcCOSClient = new COSClient(srcCredentials, new ClientConfig(srcBucketRegion));
        CopyObjectRequest copyObjectRequest = new CopyObjectRequest(srcBucketRegion, srcBucketName,
                srcKey, destBucketName, destKey);
        try {
            Copy copy = transferManager.copy(copyObjectRequest, srcCOSClient, null);
            // 返回一个异步结果 copy, 可同步的调用 waitForCopyResult 等待 copy 结束, 成功返回 CopyResult, 失败抛出异常.
            CopyResult copyResult = copy.waitForCopyResult();
            // 获取拷贝生成对象的CRC64
            String crc64Ecma = copyResult.getCrc64Ecma();
        } catch (CosServiceException e) {
            e.printStackTrace();
        } catch (CosClientException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
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
        TransferCopyObject example = new TransferCopyObject();
        example.initClient();

        // 高级接口拷贝对象
        example.transferCopyObject();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}