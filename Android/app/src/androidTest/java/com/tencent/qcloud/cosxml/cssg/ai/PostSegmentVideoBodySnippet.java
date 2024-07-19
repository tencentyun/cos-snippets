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
import com.tencent.cos.xml.model.ci.ai.PostSegmentVideoBody;
import com.tencent.cos.xml.model.ci.ai.PostSegmentVideoBodyRequest;
import com.tencent.cos.xml.model.ci.ai.PostSegmentVideoBodyResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class PostSegmentVideoBodySnippet {
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

    private void postSegmentVideoBody() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		PostSegmentVideoBodyRequest request = new PostSegmentVideoBodyRequest(bucket);
		PostSegmentVideoBody postSegmentVideoBody = new PostSegmentVideoBody();// 提交任务请求体
		request.setPostSegmentVideoBody(postSegmentVideoBody);// 设置请求
		PostSegmentVideoBody.PostSegmentVideoBodyInput postSegmentVideoBodyInput = new PostSegmentVideoBody.PostSegmentVideoBodyInput();
		postSegmentVideoBody.input = postSegmentVideoBodyInput;
		// 设置文件路径;是否必传：是
		postSegmentVideoBodyInput.object = "input/test.mp4";
		PostSegmentVideoBody.PostSegmentVideoBodyOperation postSegmentVideoBodyOperation = new PostSegmentVideoBody.PostSegmentVideoBodyOperation();
		postSegmentVideoBody.operation = postSegmentVideoBodyOperation;
		PostSegmentVideoBody.PostSegmentVideoBodySegmentVideoBody postSegmentVideoBodySegmentVideoBody = new PostSegmentVideoBody.PostSegmentVideoBodySegmentVideoBody();
		postSegmentVideoBodyOperation.segmentVideoBody = postSegmentVideoBodySegmentVideoBody;
		// 设置抠图模式 Mask：输出alpha通道结果Foreground：输出前景视频Combination：输出抠图后的前景与自定义背景合成后的视频默认值：Mask;是否必传：否
		postSegmentVideoBodySegmentVideoBody.mode = "Mask";
		// 设置抠图类型HumanSeg：人像抠图GreenScreenSeg：绿幕抠图SolidColorSeg：纯色背景抠图默认值：HumanSeg;是否必传：否
		postSegmentVideoBodySegmentVideoBody.segmentType = "HumanSeg";
		// 设置mode为 Foreground 时参数生效，背景颜色为红色，取值范围 [0, 255]， 默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.backgroundRed = "0";
		// 设置mode为 Foreground 时参数生效，背景颜色为绿色，取值范围 [0, 255]，默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.backgroundGreen = "0";
		// 设置mode为 Foreground 时参数生效，背景颜色为蓝色，取值范围 [0, 255]，默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.backgroundBlue = "0";
		// 设置调整抠图的边缘位置，取值范围为[0, 255]，默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.binaryThreshold = "0";
		// 设置纯色背景抠图的背景色（红）, 当 SegmentType 为 SolidColorSeg 生效，取值范围为 [0, 255]，默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.removeRed = "0";
		// 设置纯色背景抠图的背景色（绿）, 当 SegmentType 为 SolidColorSeg 生效，取值范围为 [0, 255]，默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.removeGreen = "0";
		// 设置纯色背景抠图的背景色（蓝）, 当 SegmentType 为 SolidColorSeg 生效，取���范围为 [0, 255]，默认值为 0;是否必传：否
		postSegmentVideoBodySegmentVideoBody.removeBlue = "0";
		PostSegmentVideoBody.PostSegmentVideoBodyOutput postSegmentVideoBodyOutput = new PostSegmentVideoBody.PostSegmentVideoBodyOutput();
		postSegmentVideoBodyOperation.output = postSegmentVideoBodyOutput;
		// 设置存储桶的地域;是否必传：是
		postSegmentVideoBodyOutput.region = "ap-chongqing";
		// 设置存储结果的存储桶;是否必传：是
		postSegmentVideoBodyOutput.bucket = "test-123456789";
		// 设置结果文件名;是否必传：是
		postSegmentVideoBodyOutput.object = "output/out.mp4";
		// 设置透传用户信息，可打印的 ASCII 码，长度不超过1024;是否必传：否
		postSegmentVideoBodyOperation.userData = "This is my data.";
		// 设置任务优先级，级别限制：0 、1 、2。级别越大任务优先级越高，默认为0;是否必传：否
		postSegmentVideoBodyOperation.jobLevel = "0";
		// 设置任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否
		postSegmentVideoBody.callBackFormat = "JSON";
		// 设置任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否
		postSegmentVideoBody.callBackType = "Url";
		// 设置任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否
		postSegmentVideoBody.callBack = "http://callback.demo.com";

		ciService.postSegmentVideoBodyAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 提交任务的结果
				// 详细字段请查看api文档或者SDK源码
				PostSegmentVideoBodyResult result = (PostSegmentVideoBodyResult) cosResult;

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
    public void testPostSegmentVideoBody() {
        initService();
        postSegmentVideoBody();
    }
}