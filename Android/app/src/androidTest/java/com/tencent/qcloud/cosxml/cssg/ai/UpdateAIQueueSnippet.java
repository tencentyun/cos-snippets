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
import com.tencent.cos.xml.model.ci.ai.UpdateAIQueue;
import com.tencent.cos.xml.model.ci.ai.UpdateAIQueueRequest;
import com.tencent.cos.xml.model.ci.ai.UpdateAIQueueResult;
import com.tencent.cos.xml.model.ci.common.NotifyConfig;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class UpdateAIQueueSnippet {
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

    private void updateAIQueue() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		UpdateAIQueueRequest request = new UpdateAIQueueRequest(bucket, "queueId");
		UpdateAIQueue updateAIQueue = new UpdateAIQueue();// 更新AI内容识别队列请求体
		request.setUpdateAIQueue(updateAIQueue);// 设置请求
		// 设置队列名称，仅支持中文、英文、数字、_、-和*，长度不超过 128;是否必传：是
		updateAIQueue.name = "My-Queue-ai";
		// 设置Active 表示队列内的作业会被调度执行Paused 表示队列暂停，作业不再会被调度执行，队列内的所有作业状态维持在暂停状态，已经执行中的任务不受影响;是否必传：是
		updateAIQueue.state = "Active";
		NotifyConfig notifyConfig = new NotifyConfig();
		updateAIQueue.notifyConfig = notifyConfig;
		// 设置回调开关OffOn;是否必传：否
		notifyConfig.state = "On";
		// 设置回调事件TaskFinish：任务完成WorkflowFinish：工作流完成;是否必传：否
		notifyConfig.event = "TaskFinish";
		// 设置回调格式XMLJSON;是否必传：否
		notifyConfig.resultFormat = "JSON";
		// 设置回调类型UrlTDMQ;是否必传：否
		notifyConfig.type = "Url";
		// 设置回调地址，不能为内网地址。;是否必传：否
		notifyConfig.url = "http://callback.demo.com";

		ciService.updateAIQueueAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 更新AI内容识别队列的结果
				// 详细字段请查看api文档或者SDK源码
				UpdateAIQueueResult result = (UpdateAIQueueResult) cosResult;

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
    public void testUpdateAIQueue() {
        initService();
        updateAIQueue();
    }
}