package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.common.MetaDataDirective;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.object.CopyObjectRequest;
import com.tencent.cos.xml.model.object.CopyObjectResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class CopyObject {

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

    /**
     * 复制对象时保留对象属性
     */
    private void copyObject() {
        //.cssg-snippet-body-start:[copy-object]
        String sourceBucket = "sourcebucket-1250000000"; //源对象所在的存储桶
        String sourceRegion = "COS_REGION"; //源对象的存储桶所在的地域
        String sourceCosPath = "sourceObject"; //源对象键
        // 构造源对象属性
        CopyObjectRequest.CopySourceStruct copySourceStruct =
                new CopyObjectRequest.CopySourceStruct(sourceBucket, sourceRegion, sourceCosPath);

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键
        CopyObjectRequest copyObjectRequest = new CopyObjectRequest(bucket, cosPath,
                copySourceStruct);

        cosXmlService.copyObjectAsync(copyObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                CopyObjectResult copyObjectResult = (CopyObjectResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });

        //.cssg-snippet-body-end
    }

    /**
     * 复制对象时替换对象属性
     */
    private void copyObjectReplaced() {
        //.cssg-snippet-body-start:[copy-object-replaced]
        String sourceBucket = "sourcebucket-1250000000"; //源对象所在的存储桶
        String sourceRegion = "COS_REGION"; //源对象的存储桶所在的地域
        String sourceCosPath = "sourceObject"; //源对象键
        // 构造源对象属性
        CopyObjectRequest.CopySourceStruct copySourceStruct =
                new CopyObjectRequest.CopySourceStruct(sourceBucket, sourceRegion, sourceCosPath);

        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键
        CopyObjectRequest copyObjectRequest = new CopyObjectRequest(bucket, cosPath,
                copySourceStruct);
        copyObjectRequest.setCopyMetaDataDirective(MetaDataDirective.REPLACED);
        copyObjectRequest.setXCOSMeta("x-cos-metadata-oldKey", "newValue");

        cosXmlService.copyObjectAsync(copyObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                CopyObjectResult copyObjectResult = (CopyObjectResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

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
    public void testCopyObject() {
        initService();

        // 复制对象时保留对象属性
        copyObject();

        // 复制对象时替换对象属性
        copyObjectReplaced();
        // .cssg-methods-pragma

    }
}
