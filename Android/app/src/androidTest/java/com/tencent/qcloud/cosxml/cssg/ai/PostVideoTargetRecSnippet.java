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
import com.tencent.cos.xml.model.ci.ai.PostVideoTargetRec;
import com.tencent.cos.xml.model.ci.ai.PostVideoTargetRecRequest;
import com.tencent.cos.xml.model.ci.ai.PostVideoTargetRecResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class PostVideoTargetRecSnippet {
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

    private void postVideoTargetRec() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		PostVideoTargetRecRequest request = new PostVideoTargetRecRequest(bucket);
		PostVideoTargetRec postVideoTargetRec = new PostVideoTargetRec();// 提交任务请求体
		request.setPostVideoTargetRec(postVideoTargetRec);// 设置请求
		PostVideoTargetRec.PostVideoTargetRecOperation postVideoTargetRecOperation = new PostVideoTargetRec.PostVideoTargetRecOperation();
		postVideoTargetRec.operation = postVideoTargetRecOperation;
		// 设置视频目标检测模板 ID;是否必传：否
		postVideoTargetRecOperation.templateId = "t1460606b9752148c4ab182f55163ba7cd";
		// 设置透传用户信息, 可打印的 ASCII 码, 长度不超过1024;是否必传：否
		postVideoTargetRecOperation.userData = "This is my data.";
		// 设置任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否
		postVideoTargetRecOperation.jobLevel = "0";
		PostVideoTargetRec.PostVideoTargetRecInput postVideoTargetRecInput = new PostVideoTargetRec.PostVideoTargetRecInput();
		postVideoTargetRec.input = postVideoTargetRecInput;
		// 设置媒体文件名;是否必传：否
		postVideoTargetRecInput.object = "input/demo.mp4";
		// 设置任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否
		postVideoTargetRec.callBackFormat = "JSON";
		// 设置任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否
		postVideoTargetRec.callBackType = "Url";
		// 设置任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否
		postVideoTargetRec.callBack = "http://callback.demo.com";

		ciService.postVideoTargetRecAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 提交任务的结果
				// 详细字段请查看api文档或者SDK源码
				PostVideoTargetRecResult result = (PostVideoTargetRecResult) cosResult;

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
    public void testPostVideoTargetRec() {
        initService();
        postVideoTargetRec();
    }
}