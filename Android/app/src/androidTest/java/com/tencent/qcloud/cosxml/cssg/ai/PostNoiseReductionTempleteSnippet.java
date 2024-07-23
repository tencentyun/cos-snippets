package com.tencent.qcloud.cosxml.cssg.ai;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CIService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.ai.PostNoiseReductionTemplete;
import com.tencent.cos.xml.model.ci.ai.PostNoiseReductionTempleteRequest;
import com.tencent.cos.xml.model.ci.ai.PostNoiseReductionTempleteResult;
import com.tencent.cos.xml.model.ci.common.NoiseReduction;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class PostNoiseReductionTempleteSnippet {
    private Context context;
    private CIService ciService;
    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {
        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {

            // 首先从您的临时密钥服务器获取包含了密钥信息的响应
			// 临时密钥生成和使用指引参见https://cloud.tencent.com/document/product/436/14048
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
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey,
                    sessionToken, startTime, expiredTime);
        }
    }

    private void postNoiseReductionTemplate() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        PostNoiseReductionTempleteRequest request = new PostNoiseReductionTempleteRequest(bucket);
        PostNoiseReductionTemplete postNoiseReductionTemplete = new PostNoiseReductionTemplete();// 创建模板请求体
        request.setPostNoiseReductionTemplete(postNoiseReductionTemplete);// 设置请求
        // 设置模板名称，仅支持中文、英文、数字、_、-和*，长度不超过 64。;是否必传：是
        postNoiseReductionTemplete.name = "TempleteName";
        NoiseReduction noiseReduction = new NoiseReduction();
        postNoiseReductionTemplete.noiseReduction = noiseReduction;
        // 设置封装格式，支持 mp3、m4a、wav;是否必传：否
        noiseReduction.format = "wav";
        // 设置采样率单位：Hz可选 8000、12000、16000、24000、32000、44100、48000;是否必传：否
        noiseReduction.samplerate = "16000";

        ciService.postNoiseReductionTempleteAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 创建模板的结果
                // 详细字段请查看api文档或者SDK源码
                PostNoiseReductionTempleteResult result = (PostNoiseReductionTempleteResult) cosResult;

            }
            @Override
            public void onFail(CosXmlRequest request, CosXmlClientException clientException, CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
    }

    private void initService() {
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-guangzhou";
        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();
        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        ciService = new CIService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testPostNoiseReductionTemplate() {
        initService();
        postNoiseReductionTemplate();
    }
}