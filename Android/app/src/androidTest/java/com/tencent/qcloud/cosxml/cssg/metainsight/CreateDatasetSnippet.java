package com.tencent.qcloud.cosxml.cssg.metainsight;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CIService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.metainsight.CreateDataset;
import com.tencent.cos.xml.model.ci.metainsight.CreateDatasetRequest;
import com.tencent.cos.xml.model.ci.metainsight.CreateDatasetResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class CreateDatasetSnippet {
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

    private void createDataset() {
		// APPID
		String appid = "1253000000";
		CreateDatasetRequest request = new CreateDatasetRequest(appid);
		CreateDataset createDataset = new CreateDataset();// 创建数据集请求体
		request.setCreateDataset(createDataset);// 设置请求
		// 设置数据集名称，同一个账户下唯一。命名规则如下： 长度为1~32字符。 只能包含小写英文字母，数字，短划线（-）。 必须以英文字母和数字开头。;是否必传：是
		createDataset.datasetName = "test";
		// 设置数据集描述信息。长度为1~256个英文或中文字符，默认值为空。;是否必传：否
		createDataset.description = "test";
		// 设置指模板，在建立元数据索引时，后端将根据模板来决定收集哪些元数据。每个模板都包含一个或多个算子，不同的算子表示不同的元数据。目前支持的模板： Official:DefaultEmptyId：默认为空的模板，表示不进行元数据的采集。 Official:COSBasicMeta：基础信息模板，包含 COS 文件基础元信息算子，表示采集 COS 文件的名称、类型、ACL等基础元信息数据。 Official:FaceSearch：人脸检索模板，包含人脸检索、COS 文件基础元信息算子。Official:ImageSearch：图像检索模板，包含图像检索、COS 文件基础元信息算子。;是否必传：否
		createDataset.templateId = "Official:COSBasicMeta";
		
		ciService.createDatasetAsync(request, new CosXmlResultListener() {
		    @Override
		    public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 创建数据集的结果
				// 详细字段请查看api文档或者SDK源码
				CreateDatasetResult result = (CreateDatasetResult) cosResult;
		
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
        String region = "ap-beijing";
        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();
        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        ciService = new CIService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testCreateDataset() {
        initService();
        createDataset();
    }
}