package com.tencent.qcloud.cosxml.cssg;

import com.tencent.cos.xml.*;
import com.tencent.cos.xml.common.*;
import com.tencent.cos.xml.exception.*;
import com.tencent.cos.xml.listener.*;
import com.tencent.cos.xml.model.*;
import com.tencent.cos.xml.model.object.*;
import com.tencent.cos.xml.model.bucket.*;
import com.tencent.cos.xml.model.tag.*;
import com.tencent.cos.xml.transfer.*;
import com.tencent.qcloud.core.auth.*;
import com.tencent.qcloud.core.common.*;
import com.tencent.qcloud.core.http.*;
import com.tencent.cos.xml.model.service.*;
import com.tencent.qcloud.cosxml.cssg.BuildConfig;

import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class BucketACL {

    private Context context;
    private CosXmlService cosXmlService;

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
     * 设置存储桶 ACL
     */
    private void putBucketAcl() {
        //.cssg-snippet-body-start:[put-bucket-acl]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        PutBucketACLRequest putBucketACLRequest = new PutBucketACLRequest(bucket);

        // 设置 bucket 访问权限
        putBucketACLRequest.setXCOSACL("public-read");

        // 赋予被授权者读的权限
        ACLAccount readACLS = new ACLAccount();
        readACLS.addAccount("100000000001", "100000000001");
        putBucketACLRequest.setXCOSGrantRead(readACLS);

        // 赋予被授权者写的权限
        ACLAccount writeACLS = new ACLAccount();
        writeACLS.addAccount("100000000001", "100000000001");
        putBucketACLRequest.setXCOSGrantWrite(writeACLS);

        // 赋予被授权者读写的权限
        ACLAccount writeandReadACLS = new ACLAccount();
        writeandReadACLS.addAccount("100000000001", "100000000001");
        putBucketACLRequest.setXCOSReadWrite(writeandReadACLS);

        cosXmlService.putBucketACLAsync(putBucketACLRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                PutBucketACLResult putBucketACLResult = (PutBucketACLResult) result;
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
     * 获取存储桶 ACL
     */
    private void getBucketAcl() {
        //.cssg-snippet-body-start:[get-bucket-acl]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        GetBucketACLRequest getBucketACLRequest = new GetBucketACLRequest(bucket);
        cosXmlService.getBucketACLAsync(getBucketACLRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketACLResult getBucketACLResult = (GetBucketACLResult) result;
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
    // .cssg-methods-pragma

    public void initService() {
        String region = "ap-guangzhou";

        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();

        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        cosXmlService = new CosXmlService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testBucketACL() {
        initService();

        // 设置存储桶 ACL
        putBucketAcl();

        // 获取存储桶 ACL
        getBucketAcl();
        // .cssg-methods-pragma

    }
}
