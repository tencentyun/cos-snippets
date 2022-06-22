package com.tencent.qcloud.cosxml.cssg;

import android.support.annotation.Nullable;

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


import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class DeleteObject {

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
     * 删除对象
     */
    private void deleteObject() {
        //.cssg-snippet-body-start:[delete-object]
        String bucket = "examplebucket-1250000000"; //存储桶名称，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即对象键

        DeleteObjectRequest deleteObjectRequest = new DeleteObjectRequest(bucket,
                cosPath);
        cosXmlService.deleteObjectAsync(deleteObjectRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                DeleteObjectResult deleteObjectResult = (DeleteObjectResult) result;
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
     * 删除多个对象
     */
    private void deleteMultiObject() {
        //.cssg-snippet-body-start:[delete-multi-object]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        List<String> objectList = new ArrayList<String>();
        objectList.add("exampleobject1"); //对象在存储桶中的位置标识符，即对象键
        objectList.add("exampleobject2"); //对象在存储桶中的位置标识符，即对象键

        DeleteMultiObjectRequest deleteMultiObjectRequest =
                new DeleteMultiObjectRequest(bucket, objectList);
        // Quiet 模式只返回报错的 Object 信息。否则返回每个 Object 的删除结果。
        deleteMultiObjectRequest.setQuiet(true);
        cosXmlService.deleteMultiObjectAsync(deleteMultiObjectRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult result) {
                DeleteMultiObjectResult deleteMultiObjectResult =
                        (DeleteMultiObjectResult) result;
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
     * 指定前缀批量删除对象
     */
    private void deletePrefix() {
        //.cssg-snippet-body-start:[delete-prefix]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String prefix = "folder1/"; //指定前缀

        GetBucketRequest getBucketRequest = new GetBucketRequest(bucket);
        getBucketRequest.setPrefix(prefix);

        // prefix表示要删除的文件夹
        getBucketRequest.setPrefix(prefix);
        // 设置最大遍历出多少个对象, 一次listobject最大支持1000
        getBucketRequest.setMaxKeys(1000);
        GetBucketResult getBucketResult = null;

        do {
            try {
                getBucketResult = cosXmlService.getBucket(getBucketRequest);
                List<ListBucket.Contents> contents = getBucketResult.listBucket.contentsList;
                DeleteMultiObjectRequest deleteMultiObjectRequest = new DeleteMultiObjectRequest(bucket);
                for (ListBucket.Contents content : contents) {
                    deleteMultiObjectRequest.setObjectList(content.key);
                }
                cosXmlService.deleteMultiObject(deleteMultiObjectRequest);
                getBucketRequest.setMarker(getBucketResult.listBucket.nextMarker);
            } catch (CosXmlClientException e) {
                e.printStackTrace();
                return;
            } catch (CosXmlServiceException e) {
                e.printStackTrace();
                return;
            }
        } while (getBucketResult.listBucket.isTruncated);

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
    public void testDeleteObjects() {
        initService();

        // 删除对象
        deleteObject();

        // 删除多个对象
        deleteMultiObject();

        // 指定前缀批量删除对象
        deletePrefix();
        
        // .cssg-methods-pragma

    }
}
