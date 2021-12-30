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

public class SetCustomDomain {

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
     * 设置默认加速域名
     */
    private void setCdnDomain() {
        //.cssg-snippet-body-start:[set-cdn-domain]
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-beijing"; // 您的存储桶地域
        // 存储桶的默认加速域名
        String cdnDomain = "examplebucket-1250000000.file.myqcloud.com";

        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .isHttps(true)
                .setRegion(region)
                .setDebuggable(false)
                .setHostFormat(cdnDomain) // 修改请求的域名
                .addHeader("Host", cdnDomain) // 修改 header 中的 host 字段
                .builder();

        // 不提供 credentialProvider 类，下载时可以通过给 url 添加 params 参数，来
        // 支持 CDN 权限校验
        CosXmlService cosXmlService = new CosXmlService(context, cosXmlServiceConfig);
        //.cssg-snippet-body-end
    }

    /**
     * 设置自定义加速域名
     */
    private void setCdnCustomDomain() {
        //.cssg-snippet-body-start:[set-cdn-custom-domain]
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-beijing"; // 您的存储桶地域
        String cdnCustomDomain = "exampledomain.com"; // 自定义加速域名

        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .isHttps(true)
                .setRegion(region)
                .setDebuggable(false)
                .setHostFormat(cdnCustomDomain) // 修改请求的域名
                .addHeader("Host", cdnCustomDomain) // 修改 header 中的 host 字段
                .builder();
        // 不提供 credentialProvider 类，下载时可以通过给 url 添加 params 参数，来
        // 支持 CDN 权限校验
        CosXmlService cosXmlService = new CosXmlService(context, cosXmlServiceConfig);
        //.cssg-snippet-body-end
    }

    /**
     * 设置自定义域名
     */
    private void setCustomDomain() {

        ServerCredentialProvider credentialProvider = new ServerCredentialProvider();
        //.cssg-snippet-body-start:[set-custom-domain]
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-beijing"; // 您的存储桶地域
        String customDomain = "exampledomain.com"; // 自定义域名

        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .isHttps(true)
                .setRegion(region)
                .setDebuggable(false)
                .setHostFormat(customDomain) // 修改请求的域名
                .builder();

        CosXmlService cosXmlService = new CosXmlService(context, cosXmlServiceConfig,
                credentialProvider);
        //.cssg-snippet-body-end
    }

    /**
     * 设置全球加速域名
     */
    private void setAccelerateDomain() {

        ServerCredentialProvider credentialProvider = new ServerCredentialProvider();

        //.cssg-snippet-body-start:[set-accelerate-domain]
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-beijing"; // 您的存储桶地域

        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .isHttps(true)
                .setRegion(region)
                .setDebuggable(false)
                .setAccelerate(true) // 使能全球加速域名
                .builder();

        CosXmlService cosXmlService = new CosXmlService(context, cosXmlServiceConfig,
                credentialProvider);
        //.cssg-snippet-body-end
    }

    /**
     * 设置请求域名后缀
     */
    private void setEndpointSuffix() {

        ServerCredentialProvider credentialProvider = new ServerCredentialProvider();
        //.cssg-snippet-body-start:[set-endpoint-suffix]
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-beijing"; // 您的存储桶地域

        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .isHttps(true)
                .setRegion(region)
                .setDebuggable(false)
                // 修改请求的域名，sdk 会自动将 ${bucket} 和 ${region} 分别替换为真正的
                // 存储桶和地域
                .setHostFormat("${bucket}.cos.${region}.example.com")
                .builder();

        CosXmlService cosXmlService = new CosXmlService(context, cosXmlServiceConfig, credentialProvider);
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
    public void testSetCustomDomain() {
        initService();

        // 设置默认加速域名
        setCdnDomain();
        
        // 设置自定义加速域名
        setCdnCustomDomain();
        
        // 设置自定义域名
        setCustomDomain();

        // 设置全球加速域名
        setAccelerateDomain();

        // 设置请求域名后缀
        setEndpointSuffix();
        
        
        
        // .cssg-methods-pragma
    }
}
