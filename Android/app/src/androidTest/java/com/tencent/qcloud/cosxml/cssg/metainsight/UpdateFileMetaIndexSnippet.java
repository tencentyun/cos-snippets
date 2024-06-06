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
import com.tencent.cos.xml.model.ci.metainsight.UpdateFileMetaIndex;
import com.tencent.cos.xml.model.ci.metainsight.UpdateFileMetaIndexRequest;
import com.tencent.cos.xml.model.ci.metainsight.UpdateFileMetaIndexResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

import java.util.ArrayList;
import java.util.HashMap;

public class UpdateFileMetaIndexSnippet {
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

    private void updateFileMetaIndex() {
		// APPID
		String appid = "1253000000";
		UpdateFileMetaIndexRequest request = new UpdateFileMetaIndexRequest(appid);
		UpdateFileMetaIndex updateFileMetaIndex = new UpdateFileMetaIndex();// 更新元数据索引请求体
		request.setUpdateFileMetaIndex(updateFileMetaIndex);// 设置请求
		// 设置数据集名称，同一个账户下唯一。;是否必传：是
		updateFileMetaIndex.datasetName = "test";
		// 设置元数据索引结果（以回调形式发送至您的回调地址，支持以 http:// 或者 https:// 开头的地址，例如： http://www.callback.com。;是否必传：否
		updateFileMetaIndex.callback = "http://www.callback.com";
		UpdateFileMetaIndex.File file = new UpdateFileMetaIndex.File();
		updateFileMetaIndex.file = file;
		// 设置自定义ID。该文件索引到数据集后，作为该行元数据的属性存储，用于和您的业务系统进行关联、对应。您可以根据业务需求传入该值，例如将某个URI关联到您系统内的某个ID。推荐传入全局唯一的值。在查询时，该字段支持前缀查询和排序，详情请见字段和操作符的支持列表。   ;是否必传：否
		file.customId = "001";
		// 设置自定义标签。您可以根据业务需要自定义添加标签键值对信息，用于在查询时可以据此为筛选项进行检索，详情请见字段和操作符的支持列表。  ;是否必传：否
		file.customLabels = new HashMap<>();
		file.customLabels.put("age", "18");
		file.customLabels.put("level", "6");
		// 设置可选项，文件媒体类型，枚举值： image：图片。  other：其他。 document：文档。 archive：压缩包。 video：视频。  audio：音频。  ;是否必传：否
		file.mediaType = "image";
		// 设置可选项，文件内容类型（MIME Type），如image/jpeg。  ;是否必传：否
		file.contentType = "image/jpeg";
		// 设置资源标识字段，表示需要建立索引的文件地址，当前仅支持COS上的文件，字段规则：cos:///，其中BucketName表示COS存储桶名称，ObjectKey表示文件完整路径，例如：cos://examplebucket-1250000000/test1/img.jpg。 注意： 1、仅支持本账号内的COS文件 2、不支持HTTP开头的地址;是否必传：是
		file.uRI = "cos://examplebucket-1250000000/test.jpg";
		// 设置输入图片中检索的人脸数量，默认值为20，最大值为20。(仅当数据集模板 ID 为 Official:FaceSearch 有效)。;是否必传：否
		file.maxFaceNum = 20;
		// 设置自定义人物属性(仅当数据集模板 ID 为 Official:FaceSearch 有效)。;是否必传：否
		file.persons = new ArrayList<>();
		UpdateFileMetaIndex.Persons person1 = new UpdateFileMetaIndex.Persons();
		person1.personId = "11111111";
		UpdateFileMetaIndex.Persons person2 = new UpdateFileMetaIndex.Persons();
		person2.personId = "22222222";
		file.persons.add(person1);
		file.persons.add(person2);
		
		ciService.updateFileMetaIndexAsync(request, new CosXmlResultListener() {
		    @Override
		    public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
				// result 更新元数据索引的结果
				// 详细字段请查看api文档或者SDK源码
				UpdateFileMetaIndexResult result = (UpdateFileMetaIndexResult) cosResult;
		
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
    public void testUpdateFileMetaIndex() {
        initService();
        updateFileMetaIndex();
    }
}