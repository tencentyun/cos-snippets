package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.bucket.DeleteBucketInventoryRequest;
import com.tencent.cos.xml.model.bucket.DeleteBucketInventoryResult;
import com.tencent.cos.xml.model.bucket.GetBucketInventoryRequest;
import com.tencent.cos.xml.model.bucket.GetBucketInventoryResult;
import com.tencent.cos.xml.model.bucket.ListBucketInventoryRequest;
import com.tencent.cos.xml.model.bucket.ListBucketInventoryResult;
import com.tencent.cos.xml.model.bucket.PutBucketInventoryRequest;
import com.tencent.cos.xml.model.bucket.PutBucketInventoryResult;
import com.tencent.cos.xml.model.tag.InventoryConfiguration;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class BucketInventory {

    private Context context;
    private CosXmlService cosXmlService;

    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {

        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {

            // 首先从您的临时密钥服务器获取包含了密钥信息的响应
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
     * 设置存储桶清单任务
     */
    private void putBucketInventory() {
        //.cssg-snippet-body-start:[put-bucket-inventory]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        PutBucketInventoryRequest putBucketInventoryRequest =
                new PutBucketInventoryRequest(bucket);
        putBucketInventoryRequest.setInventoryId("exampleInventoryId");
        // 是否在清单中包含对象版本：
        // 如果设置为 All，清单中将会包含所有对象版本，
        // 并在清单中增加VersionId，IsLatest，DeleteMarker 这几个字段
        // 如果设置为 Current，则清单中不包含对象版本信息
        putBucketInventoryRequest.setIncludedObjectVersions(InventoryConfiguration
                .IncludedObjectVersions.ALL);
        // 备份频率
        putBucketInventoryRequest.setScheduleFrequency(InventoryConfiguration
                .SCHEDULE_FREQUENCY_DAILY);
        // 备份路径
        putBucketInventoryRequest.setDestination("CSV", "1000000000",
                "examplebucket-1250000000", "region", "dir/");

        cosXmlService.putBucketInventoryAsync(putBucketInventoryRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                PutBucketInventoryResult putBucketInventoryResult =
                        (PutBucketInventoryResult) result;
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
     * 获取存储桶清单任务
     */
    private void getBucketInventory() {
        //.cssg-snippet-body-start:[get-bucket-inventory]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        GetBucketInventoryRequest getBucketInventoryRequest =
                new GetBucketInventoryRequest(bucket);
        getBucketInventoryRequest.setInventoryId("exampleInventoryId");

        cosXmlService.getBucketInventoryAsync(getBucketInventoryRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketInventoryResult getBucketInventoryResult =
                        (GetBucketInventoryResult) result;
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
     * 删除存储桶清单任务
     */
    private void deleteBucketInventory() {
        //.cssg-snippet-body-start:[delete-bucket-inventory]
		// 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        DeleteBucketInventoryRequest deleteBucketInventoryRequest =
                new DeleteBucketInventoryRequest(bucket);
        deleteBucketInventoryRequest.setInventoryId("exampleInventoryId");

        cosXmlService.deleteBucketInventoryAsync(deleteBucketInventoryRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                DeleteBucketInventoryResult deleteBucketInventoryResult =
                        (DeleteBucketInventoryResult) result;
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
     * 列出所有存储桶清单任务
     */
    private void listBucketInventory() {
        //.cssg-snippet-body-start:[list-bucket-inventory]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        ListBucketInventoryRequest request = new ListBucketInventoryRequest(bucket);
        cosXmlService.listBucketInventoryAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                ListBucketInventoryResult listBucketInventoryResult =
                        (ListBucketInventoryResult) result;
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
    public void testBucketInventory() {
        initService();

        // 设置存储桶清单任务
        putBucketInventory();

        // 获取存储桶清单任务
        getBucketInventory();

        // 删除存储桶清单任务
        deleteBucketInventory();

        // 列出所有存储桶清单任务
        listBucketInventory();

        // .cssg-methods-pragma

    }
}
