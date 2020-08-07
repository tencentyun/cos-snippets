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

public class PutObject {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 简单上传对象
     */
    public void putObject() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-object]
        // 指定要上传的文件
        File localFile = new File(localFilePath);
        // 指定要上传到的存储桶
        String bucketName = "examplebucket-1250000000";
        // 指定要上传到 COS 上对象键
        String key = "exampleobject";
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        PutObjectResult putObjectResult = cosClient.putObject(putObjectRequest);
        
        //.cssg-snippet-body-end
    }

    /**
     * 简单上传对象
     */
    public void putObjectFlex() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-object-flex]
        // Bucket的命名格式为 BucketName-APPID ，此处填写的存储桶名称必须为此格式
        String bucketName = "examplebucket-1250000000";
        // 方法1 本地文件上传
        File localFile = new File(localFilePath);
        String key = "exampleobject";
        PutObjectResult putObjectResult = cosClient.putObject(bucketName, key, localFile);
        String etag = putObjectResult.getETag();  // 获取文件的 etag
        
        // 方法2 从输入流上传(需提前告知输入流的长度, 否则可能导致 oom)
        FileInputStream fileInputStream = new FileInputStream(localFile);
        ObjectMetadata objectMetadata = new ObjectMetadata();
        // 设置输入流长度为500
        objectMetadata.setContentLength(500);
        // 设置 Content type, 默认是 application/octet-stream
        objectMetadata.setContentType("application/pdf");
        putObjectResult = cosClient.putObject(bucketName, key, fileInputStream, objectMetadata);
        etag = putObjectResult.getETag();
        // 关闭输入流...
        
        // 方法3 提供更多细粒度的控制, 常用的设置如下
        // 1 storage-class 存储类型, 枚举值：Standard，Standard_IA，Archive。默认值：Standard
        // 2 content-type, 对于本地文件上传，默认根据本地文件的后缀进行映射，例如 jpg 文件映射 为image/jpeg
        //   对于流式上传 默认是 application/octet-stream
        // 3 上传的同时指定权限(也可通过调用 API set object acl 来设置)
        // 4 若要全局关闭上传MD5校验, 则设置系统环境变量，此设置会对所有的会影响所有的上传校验。 默认是进行校验的。
        // 关闭MD5校验：  System.setProperty(SkipMd5CheckStrategy.DISABLE_PUT_OBJECT_MD5_VALIDATION_PROPERTY, "true");
        // 打开MD5校验  System.setProperty(SkipMd5CheckStrategy.DISABLE_PUT_OBJECT_MD5_VALIDATION_PROPERTY, null);
        localFile = new File(localFilePath);
        key = "picture.jpg";
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        // 设置存储类型为低频
        putObjectRequest.setStorageClass(StorageClass.Standard_IA);
        // 设置自定义属性(如 content-type, content-disposition 等)
        objectMetadata = new ObjectMetadata();
        // 限流使用的单位是 bit/s, 这里设置上传带宽限制为 10MB/s
        putObjectRequest.setTrafficLimit(80*1024*1024);
        // 设置 Content type, 默认是 application/octet-stream
        objectMetadata.setContentType("image/jpeg");
        putObjectRequest.setMetadata(objectMetadata);
        putObjectResult = cosClient.putObject(putObjectRequest);
        // 获取对象的 Etag
        etag = putObjectResult.getETag();
        // 获取对象的 CRC64
        String crc64Ecma = putObjectResult.getCrc64Ecma();
        
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
        PutObject example = new PutObject();
        example.initClient();

        // 简单上传对象
        example.putObject();

        // 简单上传对象
        example.putObjectFlex();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}