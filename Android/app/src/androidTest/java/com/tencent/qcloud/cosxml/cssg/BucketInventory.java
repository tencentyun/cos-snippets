package com.tencent.qcloud.cosxml.cssg;

import com.tencent.cos.xml.*;
import com.tencent.cos.xml.common.*;
import com.tencent.cos.xml.exception.*;
import com.tencent.cos.xml.listener.*;
import com.tencent.cos.xml.model.*;
import com.tencent.cos.xml.model.object.*;
import com.tencent.cos.xml.model.bucket.*;
import com.tencent.cos.xml.model.tag.*;
import com.tencent.cos.xml.transfer.*;
import com.tencent.qcloud.core.auth.*;
import com.tencent.qcloud.core.common.*;
import com.tencent.qcloud.core.http.*;
import com.tencent.cos.xml.model.service.*;
import com.tencent.qcloud.cosxml.cssg.BuildConfig;

import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class BucketInventory {

    private Context context;
    private CosXmlService cosXmlService;

    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {

        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {

            // 首先从您的临时密钥服务器获取包含了密钥信息的响应

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
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
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

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               CosXmlClientException clientException,
                               CosXmlServiceException serviceException) {
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
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
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

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               CosXmlClientException clientException,
                               CosXmlServiceException serviceException) {
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
        String bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
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

            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               CosXmlClientException clientException,
                               CosXmlServiceException serviceException) {
            }
        });

        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    private void initService() {
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
        // .cssg-methods-pragma

    }
}
