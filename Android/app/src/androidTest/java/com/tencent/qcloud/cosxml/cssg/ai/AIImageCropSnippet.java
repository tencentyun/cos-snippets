package com.tencent.qcloud.cosxml.cssg.ai;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.ai.AIImageCropRequest;
import com.tencent.cos.xml.model.object.GetObjectResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class AIImageCropSnippet {
    private Context context;
    private CosXmlService cosXmlService;
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

    private void aIImageCrop() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        AIImageCropRequest request = new AIImageCropRequest(bucket);
        request.objectKey = "folder/document.jpg";
        request.detectUrl = "http://www.example.com/abc.jpg";// 设置您可以通过填写 detect-url 处理任意公网可访问的图片链接。不填写 detect-url 时，后台会默认处理 ObjectKey ，填写了 detect-url 时，后台会处理 detect-url 链接，无需再填写 ObjectKey detect-url 示例：http://www.example.com/abc.jpg
        request.width = 10;// 设置需要裁剪区域的宽度，与height共同组成所需裁剪的图片宽高比例；输入数字请大于0、小于图片宽度的像素值
        request.height = 6;// 设置需要裁剪区域的高度，与width共同组成所需裁剪的图片宽高比例；输入数字请大于0、小于图片高度的像素值；width : height建议取值在[1, 2.5]之间，超过这个范围可能会影响效果
        request.fixed = 0;// 设置是否严格按照 width 和 height 的值进行输出。取值为0时，宽高比例（width : height）会简化为最简分数，即如果width输入10、height输入20，会简化为1：2；取值为1时，输出图片的宽度等于width，高度等于height；默认值为0
        request.ignoreError = 1;// 设置当此参数为1时，针对文件过大等导致处理失败的场景，会直接返回原图而不报错
        // 设置结果文件保存路径
        request.saveLocalPath = "保存到本地的路径";

        cosXmlService.aiImageCropAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 图像智能裁剪的结果
                // 详细字段请查看api文档或者SDK源码
                GetObjectResult result = (GetObjectResult) cosResult;

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
        cosXmlService = new CosXmlService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testAIImageCrop() {
        initService();
        aIImageCrop();
    }
}