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

public class ObjectPresignUrl {

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
     * 获取预签名下载链接
     */
    private void getPresignDownloadUrl() {
        //.cssg-snippet-body-start:[get-presign-download-url]
        try {
            String bucket = "examplebucket-1250000000"; //存储桶名称
            String cosPath = "exampleobject"; //即对象在存储桶中的位置标识符。
            String method = "GET"; //请求 HTTP 方法.
            PresignedUrlRequest presignedUrlRequest = new PresignedUrlRequest(bucket
                    , cosPath);
            presignedUrlRequest.setRequestMethod(method);

            String urlWithSign = cosXmlService.getPresignedURL(presignedUrlRequest);

        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }

        //.cssg-snippet-body-end
    }

    /**
     * 获取预签名上传链接
     */
    private void getPresignUploadUrl() {
        //.cssg-snippet-body-start:[get-presign-upload-url]
        try {
            String bucket = "examplebucket-1250000000"; //存储桶名称
            String cosPath = "exampleobject"; //即对象在存储桶中的位置标识符。
            String method = "PUT"; //请求 HTTP 方法
            PresignedUrlRequest presignedUrlRequest = new PresignedUrlRequest(bucket
                    , cosPath) {
                @Override
                public RequestBodySerializer getRequestBody()
                        throws CosXmlClientException {
                    //用于计算 put 等需要带上 body 的请求的签名 URL
                    return RequestBodySerializer.string("text/plain",
                            "this is test");
                }
            };
            presignedUrlRequest.setRequestMethod(method);

            String urlWithSign = cosXmlService.getPresignedURL(presignedUrlRequest);
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }

        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

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

    @Test
    public void testObjectPresignUrl() {
        initService();

        // 获取预签名下载链接
        getPresignDownloadUrl();

        // 获取预签名上传链接
        getPresignUploadUrl();
        // .cssg-methods-pragma

    }
}
