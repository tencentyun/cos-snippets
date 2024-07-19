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
import com.tencent.cos.xml.model.ci.ai.UpdateSpeechRecognitionTemplete;
import com.tencent.cos.xml.model.ci.ai.UpdateSpeechRecognitionTempleteRequest;
import com.tencent.cos.xml.model.ci.ai.UpdateSpeechRecognitionTempleteResult;
import com.tencent.cos.xml.model.ci.common.SpeechRecognition;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class UpdateSpeechRecognitionTemplateSnippet {
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

    private void updateSpeechRecognitionTemplate() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		UpdateSpeechRecognitionTempleteRequest request = new UpdateSpeechRecognitionTempleteRequest(bucket, "TempleteId");
		UpdateSpeechRecognitionTemplete updateSpeechRecognitionTemplete = new UpdateSpeechRecognitionTemplete();// 更新模板请求体
		request.setUpdateSpeechRecognitionTemplete(updateSpeechRecognitionTemplete);// 设置请求
		// 设置模板名称，仅支持中文、英文、数字、_、-和*，长度不超过 64;是否必传：是
		updateSpeechRecognitionTemplete.name = "TempleteName";
		SpeechRecognition speechRecognition = new SpeechRecognition();
		updateSpeechRecognitionTemplete.speechRecognition = speechRecognition;
		// 设置引擎模型类型，分为电话场景和非电话场景。电话场景：8k_zh：电话 8k 中文普通话通用（可用于双声道音频）8k_zh_s：电话 8k 中文普通话话者分离（仅适用于单声道音频）8k_en：电话 8k 英语 非电话场景： 6k_zh：16k 中文普通话通用16k_zh_video：16k 音视频领域16k_en：16k 英语16k_ca：16k 粤语16k_ja：16k 日语16k_zh_edu：中文教育16k_en_edu：英文教育16k_zh_medical：医疗16k_th：泰语16k_zh_dialect：多方言，支持23种方言极速 ASR 支持8k_zh、16k_zh、16k_en、16k_zh_video、16k_zh_dialect、16k_ms（马来语）、16k_zh-PY（中英粤）;是否必传：是
		speechRecognition.engineModelType = "16k_zh";
		// 设置语音声道数：1 表示单声道。EngineModelType为非电话场景仅支持单声道2 表示双声道（仅支持 8k_zh 引擎模型 双声道应分别对应通话双方）仅���持非极速ASR，为非极速ASR时，该参数必填;是否必传：否
		speechRecognition.channelNum = "1";
		// 设置识别结果返回形式：0：识别结果文本（含分段时间戳）1：词级别粒度的详细识别结果，不含标点，含语速值（词时间戳列表，一般用于生成字幕场景）2：词级别粒度的详细识别结果（包含标点、语速值）3：标点符号分段，包含每段时间戳，特别适用于字幕场景（包含词级时间、标点、语速值）仅支持非极速ASR;是否必传：否
		speechRecognition.resTextFormat = "1";
		// 设置是否过滤脏词（目前支持中文普通话引擎）0：不过滤脏词1：过滤脏词2：将脏词替换为 *;是否必传：否
		speechRecognition.filterDirty = "0";
		// 设置是否过滤语气词（目前支持中文普通话引擎）：0 表示不过滤语气词1 表示部分过滤2 表示严格过滤 ;是否必传：否
		speechRecognition.filterModal = "1";
		// 设置是否进行阿拉伯数字智能转换（目前支持中文普通话引擎）0：不转换，直接输出中文数字1：根据场景智能转换为阿拉伯数字3 ：打开数学相关数字转换仅支持非极速ASR;是否必传：否
		speechRecognition.convertNumMode = "0";
		// 设置是否开启说话人分离0：不开启1：开启(仅支持8k_zh，16k_zh，16k_zh_video，单声道音频)8k电话场景建议使用双声道来区分通话双方，设置ChannelNum=2即可，不用开启说话人分离。;是否必传：否
		speechRecognition.speakerDiarization = "1";
		// 设置说话人分离人数（需配合开启说话人分离使用），取值范围：[0, 10]0 代表自动分离（目前仅支持≤6个人）1-10代表指定说话人数分离仅支持非极速ASR;是否必传：否
		speechRecognition.speakerNumber = "0";
		// 设置是否过滤标点符号（目前支持中文普通话引擎）0：不过滤。1：过滤句末标点2：过滤所有标点;是否必传：否
		speechRecognition.filterPunc = "0";
		// 设置输出文件类型，可选txt、srt极速ASR仅支持txt非极速Asr且ResTextFormat为3时仅支持txt;是否必传：否
		speechRecognition.outputFileType = "txt";

		ciService.updateSpeechRecognitionTempleteAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 更新模板的结果
				// 详细字段请查看api文档或者SDK源码
				UpdateSpeechRecognitionTempleteResult result = (UpdateSpeechRecognitionTempleteResult) cosResult;

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
    public void testUpdateSpeechRecognitionTemplate() {
        initService();
        updateSpeechRecognitionTemplate();
    }
}