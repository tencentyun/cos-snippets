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
import com.tencent.cos.xml.model.ci.asr.CreateSpeechJobsRequest;
import com.tencent.cos.xml.model.ci.asr.CreateSpeechJobsResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class PostSpeechRecognitionSnippet {
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

    private void postSpeechRecognition() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		CreateSpeechJobsRequest request = new CreateSpeechJobsRequest(bucket);
		// 设置文件路径;是否必传：否
		request.setInputObject("input/test.mp3");
		request.setQueueId("queueId");
		// 设置输出
		request.setOutput("ap-chongqing", "test-123456789", "output/asr.txt");
		// 设置引擎模型类型
		request.setEngineModelType("8k_zh");
		// 设置语音声道数。1：单声道；2：双声道（仅支持 8k_zh 引擎模型）
		request.setChannelNum(1);
		// 设置识别结果返回形式 0： 识别结果文本(含分段时间戳)； 1：仅支持16k中文引擎，含识别结果详情(词时间戳列表，一般用于生成字幕场景)
		request.setResTextFormat(1);
		// 设置透传用户信息, 可打印的 ASCII 码, 长度不超过1024;是否必传：否
		request.setUserData("This is my data.");
		// 设置任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否
		request.setJobLevel(0);
		// 设置任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否
		request.setCallBack("http://callback.demo.com");
		// 设置任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否
		request.setCallBackFormat("XML");
		request.setCallBackType("Url");
		// 设置模板
		request.setTemplateId("templateId");

		ciService.createSpeechJobsAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 提交任务的结果
				// 详细字段请查看api文档或者SDK源码
				CreateSpeechJobsResult result = (CreateSpeechJobsResult) cosResult;

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
    public void testPostSpeechRecognition() {
        initService();
        postSpeechRecognition();
    }
}