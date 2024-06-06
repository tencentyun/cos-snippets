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
import com.tencent.cos.xml.model.ci.metainsight.DatasetFaceSearch;
import com.tencent.cos.xml.model.ci.metainsight.DatasetFaceSearchRequest;
import com.tencent.cos.xml.model.ci.metainsight.DatasetFaceSearchResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class DatasetFaceSearchSnippet {
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

    private void datasetFaceSearch() {
		// APPID
		String appid = "1253000000";
		DatasetFaceSearchRequest request = new DatasetFaceSearchRequest(appid);
		DatasetFaceSearch datasetFaceSearch = new DatasetFaceSearch();// 人脸搜索请求体
		request.setDatasetFaceSearch(datasetFaceSearch);// 设置请求
		// 设置数据集名称，同一个账户下唯一。;是否必传：是
		datasetFaceSearch.datasetName = "test";
		// 设置资源标识字段，表示需要建立索引的文件地址。;是否必传：是
		datasetFaceSearch.uRI = "cos://examplebucket-1250000000/test.jpg";
		// 设置输入图片中检索的人脸数量，默认值为1(传0或不传采用默认值)，最大值为10。;是否必传：否
		datasetFaceSearch.maxFaceNum = 1;
		// 设置检索的每张人脸返回相关人脸数量，默认值为10，最大值为100。;是否必传：否
		datasetFaceSearch.limit = 10;
		// 设置出参 Score 中，只有超过 MatchThreshold 值的结果才会返回。范围：1-100，默认值为0，推荐值为80。;是否必传：否
		datasetFaceSearch.matchThreshold = 10;
		
		ciService.datasetFaceSearchAsync(request, new CosXmlResultListener() {
		    @Override
		    public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 人脸搜索的结果
				// 详细字段请查看api文档或者SDK源码
				DatasetFaceSearchResult result = (DatasetFaceSearchResult) cosResult;
		
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
    public void testDatasetFaceSearch() {
        initService();
        datasetFaceSearch();
    }
}