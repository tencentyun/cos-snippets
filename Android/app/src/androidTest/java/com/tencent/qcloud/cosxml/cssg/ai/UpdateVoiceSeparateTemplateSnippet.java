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
import com.tencent.cos.xml.model.ci.ai.UpdateVoiceSeparateTemplete;
import com.tencent.cos.xml.model.ci.ai.UpdateVoiceSeparateTempleteRequest;
import com.tencent.cos.xml.model.ci.ai.UpdateVoiceSeparateTempleteResult;
import com.tencent.cos.xml.model.ci.common.AudioConfig;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class UpdateVoiceSeparateTemplateSnippet {
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

    private void updateVoiceSeparateTemplate() {
		// 存储桶名称，格式为 BucketName-APPID
		String bucket = "examplebucket-1250000000";
		UpdateVoiceSeparateTempleteRequest request = new UpdateVoiceSeparateTempleteRequest(bucket, "templateId");
		UpdateVoiceSeparateTemplete updateVoiceSeparateTemplete = new UpdateVoiceSeparateTemplete();// 更新模板请求体
		request.setUpdateVoiceSeparateTemplete(updateVoiceSeparateTemplete);// 设置请求
		// 设置模板名称，仅支持中文、英文、数字、_、-和*，长度不超过 64;是否必传：是
		updateVoiceSeparateTemplete.name = "TempleteName";
		// 设置输出音频IsAudio：输出人声IsBackground：输出背景声AudioAndBackground：输出人声和背景声MusicMode：输出人声、背景声、Bass声、鼓声;是否必传：是
		updateVoiceSeparateTemplete.audioMode = "IsAudio";
		AudioConfig audioConfig = new AudioConfig();
		updateVoiceSeparateTemplete.audioConfig = audioConfig;
		// 设置编解码格式，取值 aac、mp3、flac、amr。当 Request.AudioMode 为 MusicMode 时，仅支持 mp3、wav、acc;是否必传：否
		audioConfig.codec = "aac";
		// 设置采样率单位：Hz可选 8000、11025、22050、32000、44100、48000、96000当 Codec 设置为 aac/flac 时，不支持 8000当 Codec 设置为 mp3 时，不支持 8000 和 96000当 Codec 设置为 amr 时，只支持 8000当 Request.AudioMode 为 MusicMode 时，该参数无效;是否必传：否
		audioConfig.samplerate = "44100";
		// 设置音频码率单位：Kbps值范围：[8，1000]当 Request.AudioMode 为 MusicMode 时，该参数无效;是否必传：否
		audioConfig.bitrate = "128";
		// 设置声道数当 Codec 设置为 aac/flac，支持1、2、4、5、6、8当 Codec 设置为 mp3，支持1、2 当 Codec 设置为 amr，只支持1当 Request.AudioMode 为 MusicMode 时，该参数无效;是否必传：否
		audioConfig.channels = "2";

		ciService.updateVoiceSeparateTempleteAsync(request, new CosXmlResultListener() {
			@Override
			public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 更新模板的结果
				// 详细字段请查看api文档或者SDK源码
				UpdateVoiceSeparateTempleteResult result = (UpdateVoiceSeparateTempleteResult) cosResult;

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
    public void testUpdateVoiceSeparateTemplate() {
        initService();
        updateVoiceSeparateTemplate();
    }
}