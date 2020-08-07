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

public class ObjectACL {

    private COSClient cosClient;
    private TransferManager transferManager;

    private String uploadId;
    private List<PartETag> partETags;
    private String localFilePath;

    /**
     * 设置对象 ACL
     */
    public void putObjectAcl() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[put-object-acl]
        // 权限信息中身份信息有格式要求，对于主账号与子账号的范式如下：
        // 下面的 root_uin 和 sub_uin 都必须是有效的 QQ 号
        // 主账号 qcs::cam::uin/<root_uin>:uin/<root_uin> 表示授予主账号 root_uin 这个用户（即前后填的 uin 一样）
        //  如 qcs::cam::uin/2779643970:uin/2779643970
        // 子账号 qcs::cam::uin/<root_uin>:uin/<sub_uin> 表示授予 root_uin 的子账号 sub_uin 这个客户
        //  如 qcs::cam::uin/2779643970:uin/73001122 
        // 存储桶的命名格式为 BucketName-APPID
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        // 设置自定义 ACL
        AccessControlList acl = new AccessControlList();
        Owner owner = new Owner();
        // 设置 owner 的信息, owner 只能是主账号
        owner.setId("qcs::cam::uin/100000000001:uin/100000000001");
        acl.setOwner(owner);
        
        // 授权给主账号73410000可读可写权限
        UinGrantee uinGrantee1 = new UinGrantee("qcs::cam::uin/2779643970:uin/2779643970");
        acl.grantPermission(uinGrantee1, Permission.FullControl);
        cosClient.setObjectAcl(bucketName, key, acl);
        
        // 设置预定义 ACL
        // 设置私有读写（Object 的权限默认集成 Bucket的）
        cosClient.setObjectAcl(bucketName, key, CannedAccessControlList.Private);
        // 设置公有读私有写
        cosClient.setObjectAcl(bucketName, key, CannedAccessControlList.PublicRead);
        // 设置公有读写
        cosClient.setObjectAcl(bucketName, key, CannedAccessControlList.PublicReadWrite);
        
        //.cssg-snippet-body-end
    }

    /**
     * 获取对象 ACL
     */
    public void getObjectAcl() throws InterruptedException, IOException, NoSuchAlgorithmException {
        //.cssg-snippet-body-start:[get-object-acl]
        // 存储桶的命名格式为 BucketName-APPID
        String bucketName = "examplebucket-1250000000";
        String key = "exampleobject";
        AccessControlList accessControlList = cosClient.getObjectAcl(bucketName, key);
        // 将文件权限转换为预设 ACL, 可选值为：Private, PublicRead, Default
        CannedAccessControlList cannedAccessControlList = accessControlList.getCannedAccessControl();
        
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
        ObjectACL example = new ObjectACL();
        example.initClient();

        // 设置对象 ACL
        example.putObjectAcl();

        // 获取对象 ACL
        example.getObjectAcl();

        // .cssg-methods-pragma

        // 使用完成之后销毁 Client，建议 Client 保持为单例
        example.cosClient.shutdown();
    }

}