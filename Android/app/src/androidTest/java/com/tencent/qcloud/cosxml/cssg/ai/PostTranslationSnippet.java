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
import com.tencent.cos.xml.model.ci.ai.PostTranslation;
import com.tencent.cos.xml.model.ci.ai.PostTranslationRequest;
import com.tencent.cos.xml.model.ci.ai.PostTranslationResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class PostTranslationSnippet {
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

    private void postTranslation() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		PostTranslationRequest request = new PostTranslationRequest(bucket);
		PostTranslation postTranslation = new PostTranslation();// 提交任务请求体
		request.setPostTranslation(postTranslation);// 设置请求
		PostTranslation.PostTranslationInput postTranslationInput = new PostTranslation.PostTranslationInput();
		postTranslation.input = postTranslationInput;
		// 设置源文档文件名单文件（docx/xlsx/html/markdown/txt）：不超过800万字符有页数的（pdf/pptx）：不超过300页文本文件（txt）：不超过10MB二进制文件（pddocx/pptx/xlsx）：不超过60MB图片文件（jpg/jpeg/png/webp）：不超过10MB;是否必传：是
		postTranslationInput.object = "en.pdf";
		// 设置文档语言类型zh：简体中文zh-hk：繁体中文zh-tw：繁体中文zh-tr：繁体中文en：英语ar：阿拉伯语de：德语es：西班牙语fr：法语id：印尼语it：意大利语ja语pt：葡萄牙语ru：俄语ko：韩语km：高棉语lo：老挝语;是否必传：是
		postTranslationInput.lang = "en";
		// 设置文档类型pdfdocxpptxxlsxtxtxmlhtml：只能翻译 HTML 里的文本节点，需要通过 JS 动态加载的不进行翻译markdownjpgjpegpngwebp;是否必传：是
		postTranslationInput.type = "pdf";
		// 设置原始文档类型仅在 Type=pdf/jpg/jpeg/png/webp 时使用，当值为pdf时，仅支持 docx、pptx当值为jpg/jpeg/png/webp时，仅支持txt;是否必传：否
		postTranslationInput.basicType = "pptx";
		PostTranslation.PostTranslationOperation postTranslationOperation = new PostTranslation.PostTranslationOperation();
		postTranslation.operation = postTranslationOperation;
		PostTranslation.PostTranslationTranslation postTranslationTranslation = new PostTranslation.PostTranslationTranslation();
		postTranslationOperation.translation = postTranslationTranslation;
		// 设置目标语言类型源语言类型为 zh/zh-hk/zh-tw/zh-tr 时支持：en、ar、de、es、fr、id、it、ja、it、ru、ko、km、lo、pt源语言类型为 en 时支持：zzh-hk、zh-tw、zh-tr、ar、de、es、fr、id、it、ja、it、ru、ko、km、lo、pt其他类型时支持：zh、zh-hk、zh-tw、zh-tr、en;是否必传：是
		postTranslationTranslation.lang = "zh";
		// 设置文档类型，源文件类型与目标文件类型映射关系如下：docx：docxpptx：pptxxlsx：xlsxtxt：txtxml：xmlhtml：htmlmarkdown：markdownpdf：pddocxpng：txtjpg：txtjpeg：txtwebp：txt;是否必传：是
		postTranslationTranslation.type = "pdf";
		PostTranslation.PostTranslationOutput postTranslationOutput = new PostTranslation.PostTranslationOutput();
		postTranslationOperation.output = postTranslationOutput;
		// 设置存储桶的地域;是否必传：是
		postTranslationOutput.region = "ap-chongqing";
		// 设置存储结果的存储桶;是否必传：是
		postTranslationOutput.bucket = "test-123456789";
		// 设置输出结果的文件名;是否必传：是
		postTranslationOutput.object = "output/zh.pdf";
		// 设置透传用户信息，可打印的 ASCII 码，长度不超过1024;是否必传：否
		postTranslationOperation.userData = "This is my data.";
		// 设置任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否
		postTranslationOperation.jobLevel = "0";
		// 设置任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否
		postTranslation.callBackFormat = "JSON";
		// 设置任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否
		postTranslation.callBack = "http://callback.demo.com";

		ciService.postTranslationAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 提交任务的结果
				// 详细字段请查看api文档或者SDK源码
				PostTranslationResult result = (PostTranslationResult) cosResult;

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
    public void testPostTranslation() {
        initService();
        postTranslation();
    }
}