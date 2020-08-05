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

public class BucketCORS {

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
     * 设置存储桶跨域规则
     */
    private void putBucketCors() {
        //.cssg-snippet-body-start:[put-bucket-cors]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        PutBucketCORSRequest putBucketCORSRequest = new PutBucketCORSRequest(bucket);

        CORSConfiguration.CORSRule corsRule = new CORSConfiguration.CORSRule();

        // 配置规则的 ID
        corsRule.id = "123";
        // 允许的访问来源，支持通配符 *，格式为：协议://域名[:端口]
        corsRule.allowedOrigin = "https://cloud.tencent.com";
        // 设置 OPTIONS 请求得到结果的有效期
        corsRule.maxAgeSeconds = 5000;

        List<String> methods = new LinkedList<>();
        methods.add("PUT");
        methods.add("POST");
        methods.add("GET");
        // 允许的 HTTP 操作，例如：GET，PUT，HEAD，POST，DELETE
        corsRule.allowedMethod = methods;

        List<String> headers = new LinkedList<>();
        headers.add("host");
        headers.add("content-type");
        // 在发送 OPTIONS 请求时告知服务端，接下来的请求可以使用的 HTTP 请求头部，支持通配符 *
        corsRule.allowedHeader = headers;

        List<String> exposeHeaders = new LinkedList<>();
        exposeHeaders.add("x-cos-meta-1");
        // 设置浏览器可以接收到的来自服务端的自定义头部信息
        corsRule.exposeHeader = exposeHeaders;

        putBucketCORSRequest.addCORSRule(corsRule);

        cosXmlService.putBucketCORSAsync(putBucketCORSRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                PutBucketCORSResult putBucketCORSResult = (PutBucketCORSResult) result;
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
     * 获取存储桶跨域规则
     */
    private void getBucketCors() {
        //.cssg-snippet-body-start:[get-bucket-cors]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        GetBucketCORSRequest getBucketCORSRequest = new GetBucketCORSRequest(bucket);
        cosXmlService.getBucketCORSAsync(getBucketCORSRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketCORSResult getBucketCORSResult = (GetBucketCORSResult) result;
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
     * 实现 Object 跨域访问配置的预请求
     */
    private void optionObject() {
        //.cssg-snippet-body-start:[option-object]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象位于存储桶中的位置标识符，即对象键
        String origin = "https://cloud.tencent.com";
        String accessMethod = "PUT";
        OptionObjectRequest optionObjectRequest = new OptionObjectRequest(bucket,
                cosPath, origin,
                accessMethod);
        cosXmlService.optionObjectAsync(optionObjectRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                OptionObjectResult optionObjectResult = (OptionObjectResult) result;
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
     * 删除存储桶跨域规则
     */
    private void deleteBucketCors() {
        //.cssg-snippet-body-start:[delete-bucket-cors]
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        DeleteBucketCORSRequest deleteBucketCORSRequest =
                new DeleteBucketCORSRequest(bucket);
        cosXmlService.deleteBucketCORSAsync(deleteBucketCORSRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                DeleteBucketCORSResult deleteBucketCORSResult =
                        (DeleteBucketCORSResult) result;
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
    public void testBucketCORS() {
        initService();

        // 设置存储桶跨域规则
        putBucketCors();

        // 获取存储桶跨域规则
        getBucketCors();

        // 实现 Object 跨域访问配置的预请求
        optionObject();

        // 删除存储桶跨域规则
        deleteBucketCors();
        // .cssg-methods-pragma

    }
}
