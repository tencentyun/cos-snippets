package com.tencent.qcloud.cosxml.cssg;

import android.support.annotation.Nullable;

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


import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class SetCustomHeaders {

    private Context context;
    private CosXmlService cosXmlService;

    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {
        
        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {
    
            // 首先从您的临时密钥服务器获取包含了密钥信息的响应
			// 临时密钥生成和使用指引参见https://cloud.tencent.com/document/product/436/14048
    
            // 然后解析响应，获取密钥信息
            String tmpSecretId = "临时密钥 secretId";
            String tmpSecretKey = "临时密钥 secretKey";
            String sessionToken = "临时密钥 TOKEN";
            long expiredTime = 1556183496L;//临时密钥有效截止时间戳，单位是秒
    
            /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
            // 返回服务器时间作为签名的起始时间
            long startTime = 1556182000L; //临时密钥有效起始时间，单位是秒
    
            // 最后返回临时密钥信息对象
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey, sessionToken, startTime, expiredTime);
        }
    }

    /**
     * 设置自定义头部
     */
    private void setCustomHeaders() {

        String bucket = null;
        String cosPath = null;
        ServerCredentialProvider credentialProvider = new ServerCredentialProvider();
        //.cssg-snippet-body-start:[set-custom-headers]
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-beijing"; // 您的存储桶地域
        String commonHeaderKey = "commonexamplekey"; // 自定义公共 Header 的键
        String commonHeaderValue = "commonexamplevalue"; // 自定义公共 Header 的值
        String requestHeaderKey = "requestexamplekey"; // 自定义请求 Header 的键
        String requestHeaderValue = "requestexamplevalue"; // 自定义请求 Header 的值

        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .isHttps(true)
                .setRegion(region)
                .setDebuggable(false)
                // 给所有的请求添加公共的自定义 Header
                .addHeader(commonHeaderKey, commonHeaderValue)
                .builder();

        CosXmlService cosXmlService = new CosXmlService(context, cosXmlServiceConfig,
                credentialProvider);

        // 给单个请求添加自定义 Header，优先级比公共 Header 更高
        HeadObjectRequest headObjectRequest = new HeadObjectRequest(bucket, cosPath);
        try {
            headObjectRequest.setRequestHeaders(requestHeaderKey, requestHeaderValue, false);
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        }

        // 发起请求
        cosXmlService.headObjectAsync(headObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                HeadObjectResult headObjectResult = (HeadObjectResult) result;
            }

            @Override
            public void onFail(CosXmlRequest request, CosXmlClientException clientException,
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
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-guangzhou";
        
        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();
        
        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        cosXmlService = new CosXmlService(context, serviceConfig, new ServerCredentialProvider());
    }

    @Test
    public void testSetCustomHeaders() {
        initService();

        // 设置自定义头部
        setCustomHeaders();
        
        // .cssg-methods-pragma
    }
}
