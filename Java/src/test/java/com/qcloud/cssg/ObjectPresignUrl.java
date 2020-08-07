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

public class ObjectPresignUrl {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 获取预签名下载链接
     */
    public void getPresignDownloadUrl() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[get-presign-download-url]
        // 初始化永久密钥信息
        String secretId = "COS_SECRETID";
        String secretKey = "COS_SECRETKEY";
        COSCredentials cred = new BasicCOSCredentials(secretId, secretKey);
        Region region = new Region("COS_REGION");
        ClientConfig clientConfig = new ClientConfig(region);
        // 生成 cos 客户端。
        COSClient cosClient = new COSClient(cred, clientConfig);
        // 存储桶的命名格式为 BucketName-APPID，此处填写的存储桶名称必须为此格式
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        GeneratePresignedUrlRequest req =
                new GeneratePresignedUrlRequest(bucketName, key, HttpMethodName.GET);
        // 设置签名过期时间(可选), 若未进行设置, 则默认使用 ClientConfig 中的签名过期时间(1小时)
        // 这里设置签名在半个小时后过期
        Date expirationDate = new Date(System.currentTimeMillis() + 30L * 60L * 1000L);
        req.setExpiration(expirationDate);
        URL url = cosClient.generatePresignedUrl(req);
        System.out.println(url.toString());
        cosClient.shutdown();
        
        //.cssg-snippet-body-end
    }

    /**
     * 获取预签名上传链接
     */
    public void getPresignUploadUrl() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[get-presign-upload-url]
        // 存储桶的命名格式为 BucketName-APPID，此处填写的存储桶名称必须为此格式
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        // 设置签名过期时间(可选), 若未进行设置, 则默认使用 ClientConfig 中的签名过期时间(1小时)
        // 这里设置签名在半个小时后过期
        Date expirationTime = new Date(System.currentTimeMillis() + 30L * 60L * 1000L);
        URL url = cosClient.generatePresignedUrl(bucketName, key, expirationTime, HttpMethodName.PUT);
        System.out.println(url.toString());
        cosClient.shutdown();
        
        //.cssg-snippet-body-end
    }

    /**
     * 获取预签名下载链接
     */
    public void getPresignDownloadUrlOverrideHeaders() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[get-presign-download-url-override-headers]
        // 传入获取到的临时密钥 (tmpSecretId, tmpSecretKey, sessionToken)
        String tmpSecretId = "COS_SECRETID";
        String tmpSecretKey = "COS_SECRETKEY";
        String sessionToken = "COS_TOKEN";
        COSCredentials cred = new BasicSessionCredentials(tmpSecretId, tmpSecretKey, sessionToken);
        // 设置 bucket 的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
        // clientConfig 中包含了设置 region, https(默认 http), 超时, 代理等 set 方法, 使用可参见源码或者常见问题 Java SDK 部分
        Region region = new Region("COS_REGION");
        ClientConfig clientConfig = new ClientConfig(region);
        // 生成 cos 客户端
        COSClient cosClient = new COSClient(cred, clientConfig);
        // 存储桶的命名格式为 BucketName-APPID 
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        GeneratePresignedUrlRequest req =
                new GeneratePresignedUrlRequest(bucketName, key, HttpMethodName.GET);
        // 设置下载时返回的 http 头
        ResponseHeaderOverrides responseHeaders = new ResponseHeaderOverrides();
        String responseContentType = "image/x-icon";
        String responseContentLanguage = "zh-CN";
        String responseContentDispositon = "filename=\"exampleobject\"";
        String responseCacheControl = "no-cache";
        String cacheExpireStr =
                DateUtils.formatRFC822Date(new Date(System.currentTimeMillis() + 24L * 3600L * 1000L));
        responseHeaders.setContentType(responseContentType);
        responseHeaders.setContentLanguage(responseContentLanguage);
        responseHeaders.setContentDisposition(responseContentDispositon);
        responseHeaders.setCacheControl(responseCacheControl);
        responseHeaders.setExpires(cacheExpireStr);
        req.setResponseHeaders(responseHeaders);
        // 设置签名过期时间(可选)，若未进行设置，则默认使用 ClientConfig 中的签名过期时间(1小时)
        // 这里设置签名在半个小时后过期
        Date expirationDate = new Date(System.currentTimeMillis() + 30L * 60L * 1000L);
        req.setExpiration(expirationDate);
        URL url = cosClient.generatePresignedUrl(req);
        System.out.println(url.toString());
        cosClient.shutdown();
        
        //.cssg-snippet-body-end
    }

    /**
     * 获取预签名下载链接
     */
    public void getPresignDownloadUrlPublic() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[get-presign-download-url-public]
        // 生成匿名的请求签名，需要重新初始化一个匿名的 cosClient
        // 初始化用户身份信息, 匿名身份不用传入 SecretId、SecretKey 等密钥信息
        COSCredentials cred = new AnonymousCOSCredentials();
        // 设置 bucket 的区域，COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
        ClientConfig clientConfig = new ClientConfig(new Region("ap-beijing"));
        // 生成 cos 客户端
        COSClient cosClient = new COSClient(cred, clientConfig);
        // bucket 名需包含 appid
        String bucketName = "examplebucket-1250000000";
        
        String key = "exampleobject";
        GeneratePresignedUrlRequest req =
                new GeneratePresignedUrlRequest(bucketName, key, HttpMethodName.GET);
        URL url = cosClient.generatePresignedUrl(req);
        System.out.println(url.toString());
        cosClient.shutdown();
        
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
        ObjectPresignUrl example = new ObjectPresignUrl();
        example.initClient();

        // 获取预签名下载链接
        example.getPresignDownloadUrl();

        // 获取预签名上传链接
        example.getPresignUploadUrl();

        // 获取预签名下载链接
        example.getPresignDownloadUrlOverrideHeaders();

        // 获取预签名下载链接
        example.getPresignDownloadUrlPublic();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}