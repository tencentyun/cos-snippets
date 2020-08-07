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

public class PutObjectCSE {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 使用 AES256 进行客户端加密
     */
    public void putObjectCseCAes() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-object-cse-c-aes]
        // 初始化用户身份信息(secretId, secretKey)
        String secretId = "COS_SECRETID";
        String secretKey = "COS_SECRETKEY";
        COSCredentials cred = new BasicCOSCredentials(secretId, secretKey);
        // 设置存储桶地域，COS 地域的简称请参照 https://www..com/document/product/436/6224
        ClientConfig clientConfig = new ClientConfig(new Region("COS_REGION"));
        
        // 生成对称密钥，您可以将其保存在文件中
        KeyGenerator symKeyGenerator = KeyGenerator.getInstance("AES");
        symKeyGenerator.init(256);
        SecretKey symKey = symKeyGenerator.generateKey();
        
        EncryptionMaterials encryptionMaterials = new EncryptionMaterials(symKey);
        // 使用 AES/GCM 模式，并将加密信息存储在文件元数据中
        CryptoConfiguration cryptoConf = new CryptoConfiguration(CryptoMode.AuthenticatedEncryption)
                .withStorageMode(CryptoStorageMode.ObjectMetadata);
        
        // 生成加密客户端 EncryptionClient，COSEncryptionClient 是 COSClient 的子类, 所有 COSClient 支持的接口他都支持。
        // EncryptionClient 覆盖了 COSClient 上传下载逻辑，操作内部会执行加密操作，其他操作执行逻辑和 COSClient 一致
        COSEncryptionClient cosEncryptionClient =
                new COSEncryptionClient(new COSStaticCredentialsProvider(cred),
                        new StaticEncryptionMaterialsProvider(encryptionMaterials), clientConfig,
                        cryptoConf);
        
        // 上传文件
        // 这里给出 putObject 的示例, 对于高级 API 上传，只用在生成 TransferManager 时传入 COSEncryptionClient 对象即可
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        File localFile = new File(localFilePath);
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        cosEncryptionClient.putObject(putObjectRequest);
        cosEncryptionClient.shutdown();
        
        //.cssg-snippet-body-end
    }

    /**
     * 使用 RSA 进行客户端加密
     */
    public void putObjectCseCRsa() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-object-cse-c-rsa]
        // 初始化用户身份信息(secretId, secretKey)
        String secretId = "COS_SECRETID";
        String secretKey = "COS_SECRETKEY";
        COSCredentials cred = new BasicCOSCredentials(secretId, secretKey);
        // 设置存储桶地域，COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
        ClientConfig clientConfig = new ClientConfig(new Region("COS_REGION"));
        
        // 生成非对称密钥
        KeyPairGenerator keyGenerator = KeyPairGenerator.getInstance("RSA");
        SecureRandom srand = new SecureRandom();
        keyGenerator.initialize(1024, srand);
        KeyPair asymKeyPair = keyGenerator.generateKeyPair();
        
        EncryptionMaterials encryptionMaterials = new EncryptionMaterials(asymKeyPair);
        // 使用 AES/GCM 模式，并将加密信息存储在文件元数据中
        CryptoConfiguration cryptoConf = new CryptoConfiguration(CryptoMode.AuthenticatedEncryption)
                .withStorageMode(CryptoStorageMode.ObjectMetadata);
        
        // 生成加密客户端 EncryptionClient, COSEncryptionClient 是 COSClient 的子类, 所有COSClient 支持的接口他都支持。
        // EncryptionClient 覆盖了 COSClient 上传下载逻辑，操作内部会执行加密操作，其他操作执行逻辑和 COSClient 一致
        COSEncryptionClient cosEncryptionClient =
                new COSEncryptionClient(new COSStaticCredentialsProvider(cred),
                        new StaticEncryptionMaterialsProvider(encryptionMaterials), clientConfig,
                        cryptoConf);
        
        // 上传文件
        // 这里给出 putObject 的示例，对于高级 API 上传，只用在生成 TransferManager 时传入 COSEncryptionClient 对象即可
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        File localFile = new File(localFilePath);
        PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, key, localFile);
        cosEncryptionClient.putObject(putObjectRequest);
        cosEncryptionClient.shutdown();
        
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
        PutObjectCSE example = new PutObjectCSE();
        example.initClient();

        // 使用 AES256 进行客户端加密
        example.putObjectCseCAes();

        // 使用 RSA 进行客户端加密
        example.putObjectCseCRsa();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}