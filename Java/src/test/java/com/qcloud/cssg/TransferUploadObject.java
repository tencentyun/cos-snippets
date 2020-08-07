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

public class TransferUploadObject {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 高级接口上传对象
     */
    public void transferUploadFile() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[transfer-upload-file]
        // 示例1：
        // 存储桶的命名格式为 BucketName-APPID，此处填写的存储桶名称必须为此格式
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        File localFile = new File(localFilePath);
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        // 本地文件上传
        Upload upload = transferManager.upload(putObjectRequest);
        // 等待传输结束（如果想同步的等待上传结束，则调用 waitForCompletion）
        UploadResult uploadResult = upload.waitForUploadResult();
        
        // 示例2：对大于分块大小的文件，使用断点续传
        // 步骤一：获取 PersistableUpload
        bucketName = "examplebucket-1250000000";
        key = "exmpleobject";
        localFile = new File("exmpleobject");
        putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        // 本地文件上传
        PersistableUpload persistableUpload = null;
        // 设置 SDK 内部简单上传或每个分块上传速度为8MB/s，单位：bit/s
        // 注意：大于分块阈值的 File 类型数据上传，会并发多分块上传，需要调整线程池大小，以控制上传速度
        putObjectRequest.setTrafficLimit(64*1024*1024);
        upload = transferManager.upload(putObjectRequest);
        // 等待"分块上传初始化"完成，并获取到 persistableUpload （包含 uploadId 等）
        while(persistableUpload == null) {
            persistableUpload = upload.getResumeableMultipartUploadId();
            Thread.sleep(100);
        }
        // 保存 persistableUpload
        
        // 步骤二：当由于网络等问题，大文件的上传被中断，则根据 PersistableUpload 恢复该文件的上传，只上传未上传的分块
        Upload newUpload = transferManager.resumeUpload(persistableUpload);
         // 等待传输结束（如果想同步的等待上传结束，则调用 waitForCompletion）
        uploadResult = newUpload.waitForUploadResult();
        // 服务端计算得到的对象 CRC64
        String crc64Ecma = uploadResult.getCrc64Ecma();
        
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
        TransferUploadObject example = new TransferUploadObject();
        example.initClient();

        // 高级接口上传对象
        example.transferUploadFile();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}