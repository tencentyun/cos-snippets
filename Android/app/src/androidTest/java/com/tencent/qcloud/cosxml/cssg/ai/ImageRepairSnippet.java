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
import com.tencent.cos.xml.model.ci.ai.ImageRepairRequest;
import com.tencent.cos.xml.model.object.GetObjectResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class ImageRepairSnippet {
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

    private void imageRepair() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        ImageRepairRequest request = new ImageRepairRequest(bucket, "folder/document.jpg");
        // 设置遮罩 例如： [[[608, 794], [1024, 794], [1024, 842], [608, 842]],[[1295, 62], [1295, 30], [1597, 32],[1597,64]]] ，顺时针输⼊多边形的每个点的坐标,每个多边形: [[x1, y1], [x2, y2]...] , 形式为三维矩阵（多个多边形： [多边形1,多边形2] ）或⼆维矩阵（单个多边形），且需要经过 URL 安全的 Base64 编码
        request.maskPoly = "W1tbNjA4LCA3OTRdLCBbMTAyNCwgNzk0XSwgWzEwMjQsIDg0Ml0sIFs2MDgsIDg0Ml1dLFtbMTI5NSwgNjJdLCBbMTI5NSwgMzBdLCBbMTU5NywgMzJdLFsxNTk3LDY0XV1d";
        // 设置结果文件保存路径
        request.saveLocalPath = "保存到本地的路径";

        cosXmlService.imageRepairAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 图像修复的结果
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
    public void testImageRepair() {
        initService();
        imageRepair();
    }
}