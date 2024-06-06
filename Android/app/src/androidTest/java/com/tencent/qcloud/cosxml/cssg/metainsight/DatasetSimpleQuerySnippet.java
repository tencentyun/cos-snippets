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
import com.tencent.cos.xml.model.ci.metainsight.DatasetSimpleQuery;
import com.tencent.cos.xml.model.ci.metainsight.DatasetSimpleQueryRequest;
import com.tencent.cos.xml.model.ci.metainsight.DatasetSimpleQueryResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

import java.util.ArrayList;

public class DatasetSimpleQuerySnippet {
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

    private void datasetSimpleQuery() {
		// APPID
		String appid = "1253000000";
		DatasetSimpleQueryRequest request = new DatasetSimpleQueryRequest(appid);
		DatasetSimpleQuery datasetSimpleQuery = new DatasetSimpleQuery();// 简单查询请求体
		request.setDatasetSimpleQuery(datasetSimpleQuery);// 设置请求
		// 设置数据集名称，同一个账户下唯一。;是否必传：是
		datasetSimpleQuery.datasetName = "test";
		// 设置返回文件元数据的最大个数，取值范围为0-200。 使用聚合参数时，该值表示返回分组的最大个数，取值范围为0-2000。 不设置此参数或者设置为0时，则取默认值100。;是否必传：否
		datasetSimpleQuery.maxResults = 100;
		// 设置排序字段列表。请参考字段和操作符的支持列表。 多个排序字段可使用半角逗号（,）分隔，例如：Size,Filename。 最多可设置5个排序字段。 排序字段顺序即为排序优先级顺序。;是否必传：是
		datasetSimpleQuery.sort = "CustomId";
		// 设置排序字段的排序方式。取值如下： asc：升序； desc（默认）：降序。 多个排序方式可使用半角逗号（,）分隔，例如：asc,desc。 排序方式不可多于排序字段，即参数Order的元素数量需小于等于参数Sort的元素数量。例如Sort取值为Size,Filename时，Order可取值为asc,desc或asc。 排序方式少于排序字段时，未排序的字段默认取值asc。例如Sort取值为Size,Filename，Order取值为asc时，Filename默认排序方式为asc，即升序排列;是否必传：是
		datasetSimpleQuery.order = "desc";
		DatasetSimpleQuery.Query query = new DatasetSimpleQuery.Query();
		datasetSimpleQuery.query = query;
		// 设置操作运算符。枚举值： not：逻辑非。 or：逻辑或。 and：逻辑与。 lt：小于。 lte：小于等于。 gt：大于。 gte：大于等于。 eq：等于。 exist：存在性查询。 prefix：前缀查询。 match-phrase：字符串匹配查询。 nested：字段为数组时，其中同一对象内逻辑条件查询。;是否必传：是
		query.operation = "and";
		// 设置子查询的结构体。 只有当Operations为逻辑运算符（and、or、not或nested）时，才能设置子查询条件。 在逻辑运算符为and/or/not时，其SubQueries内描述的所有条件需符合父级设置的and/or/not逻辑关系。 在逻辑运算符为nested时，其父级的Field必须为一个数组类的字段（如：Labels）。 子查询条件SubQueries组的Operation必须为and/or/not中的一个或多个，其Field必须为父级Field的子属性。;是否必传：否
		query.subQueries = new ArrayList<>();
		DatasetSimpleQuery.SubQueries subQuerie1 = new DatasetSimpleQuery.SubQueries();
		subQuerie1.field = "ContentType";
		subQuerie1.value = "image/jpeg";
		subQuerie1.operation = "eq";
		DatasetSimpleQuery.SubQueries subQuerie2 = new DatasetSimpleQuery.SubQueries();
		subQuerie2.field = "Size";
		subQuerie2.value = "10";
		subQuerie2.operation = "gt";
		query.subQueries.add(subQuerie1);
		query.subQueries.add(subQuerie2);
		
		ciService.datasetSimpleQueryAsync(request, new CosXmlResultListener() {
		    @Override
		    public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 简单查询的结果
				// 详细字段请查看api文档或者SDK源码
				DatasetSimpleQueryResult result = (DatasetSimpleQueryResult) cosResult;
		
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
    public void testDatasetSimpleQuery() {
        initService();
        datasetSimpleQuery();
    }
}