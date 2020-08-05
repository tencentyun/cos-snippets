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

public class ListObjects {

    private Context context;
    private CosXmlService cosXmlService;
    private GetBucketResult prevPageResult;

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
     * 获取首页对象列表
     */
    private void getBucket() {
        //.cssg-snippet-body-start:[get-bucket]
        String bucketName = "examplebucket-1250000000"; //格式：BucketName-APPID;
        final GetBucketRequest getBucketRequest = new GetBucketRequest(bucketName);

        // 前缀匹配，用来规定返回的对象前缀地址
        getBucketRequest.setPrefix("dir/");

        // 单次返回最大的条目数量，默认1000
        getBucketRequest.setMaxKeys(100);

        cosXmlService.getBucketAsync(getBucketRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketResult getBucketResult = (GetBucketResult) result;
                if (getBucketResult.listBucket.isTruncated) {
                    // 表示数据被截断，需要拉取下一页数据
                    prevPageResult = getBucketResult;
                }
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
     * 获取下一页对象列表
     */
    private void getBucketNextPage() {
        //.cssg-snippet-body-start:[get-bucket-next-page]
        String bucketName = "examplebucket-1250000000"; //格式：BucketName-APPID;


        GetBucketRequest getBucketRequest = new GetBucketRequest(bucketName);

        // 前缀匹配，用来规定返回的对象前缀地址
        getBucketRequest.setPrefix("dir/");

        // prevPageResult 是上一页的返回结果，这里的 nextMarker 表示下一页的起始位置
        String nextMarker = prevPageResult.listBucket.nextMarker;
        getBucketRequest.setMarker(nextMarker);

        // 单次返回最大的条目数量，默认1000
        getBucketRequest.setMaxKeys(100);

        cosXmlService.getBucketAsync(getBucketRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketResult getBucketResult = (GetBucketResult) result;
                if (getBucketResult.listBucket.isTruncated) {
                    // 表示数据被截断，需要拉取下一页数据
                }
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
     * 获取对象列表与子目录
     */
    private void getBucketWithDelimiter() {
        //.cssg-snippet-body-start:[get-bucket-with-delimiter]
        String bucketName = "examplebucket-1250000000"; //格式：BucketName-APPID;
        GetBucketRequest getBucketRequest = new GetBucketRequest(bucketName);

        // 前缀匹配，用来规定返回的对象前缀地址
        getBucketRequest.setPrefix("dir/");

        // 单次返回最大的条目数量，默认1000
        getBucketRequest.setMaxKeys(100);

        // 定界符为一个符号，如果有 Prefix，
        // 则将 Prefix 到 delimiter 之间的相同路径归为一类，定义为 Common Prefix，
        // 然后列出所有 Common Prefix。如果没有 Prefix，则从路径起点开始
        getBucketRequest.setDelimiter("/");

        cosXmlService.getBucketAsync(getBucketRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketResult getBucketResult = (GetBucketResult) result;
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
    public void testListObjects() {
        initService();

        // 获取首页对象列表
        getBucket();

        // 获取第二页对象列表
        getBucketNextPage();

        // 获取对象列表与子目录
        getBucketWithDelimiter();
        // .cssg-methods-pragma

    }
}
