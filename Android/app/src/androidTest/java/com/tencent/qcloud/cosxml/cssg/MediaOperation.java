package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.GetDescribeMediaBucketsRequest;
import com.tencent.cos.xml.model.ci.GetDescribeMediaBucketsResult;
import com.tencent.cos.xml.model.ci.GetMediaInfoRequest;
import com.tencent.cos.xml.model.ci.GetMediaInfoResult;
import com.tencent.cos.xml.model.ci.GetSnapshotRequest;
import com.tencent.cos.xml.model.ci.GetSnapshotResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class MediaOperation {
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

    private void initService() {
        String region = "ap-guangzhou";

        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();

        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        cosXmlService = new CosXmlService(context, serviceConfig,
                new BucketWebsite.ServerCredentialProvider());
    }

    /**
     * 查询已经开通媒体处理功能的存储桶
     */
    private void getDescribeMediaBuckets() {
        //.cssg-snippet-body-start:[describe-media-buckets]
        GetDescribeMediaBucketsRequest request = new GetDescribeMediaBucketsRequest();
        // 地域信息，例如 ap-shanghai、ap-beijing，若查询多个地域以“,”分隔字符串，支持中国大陆地域
        request.setRegions("ap-guangzhou,ap-beijing");
        // 存储桶名称，以“,”分隔，支持多个存储桶，精确搜索
        request.setBucketNames("examplebucket-1250000000");
        // 存储桶名称前缀，前缀搜索
        request.setBucketName("example");
        // 第几页
        request.setPageNumber(1);
        // 每页个数
        request.setPageSize(20);
        cosXmlService.getDescribeMediaBucketsAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询到的已经开通媒体处理功能的存储桶
                // 详细字段请查看api文档或者SDK源码 DescribeMediaBucketsResult类
                GetDescribeMediaBucketsResult result = (GetDescribeMediaBucketsResult) cosResult;
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
        //.cssg-snippet-body-end
    }

    /**
     * 获取媒体文件的信息
     */
    private void getMediaInfo() {
        //.cssg-snippet-body-start:[get-media-info]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String cosPath = "exampleobject";
        GetMediaInfoRequest request = new GetMediaInfoRequest(bucket, cosPath);
        cosXmlService.getMediaInfoAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 获取到的媒体文件的信息
                // 详细字段请查看api文档或者SDK源码 MediaInfo类
                GetMediaInfoResult result = (GetMediaInfoResult) cosResult;
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
        //.cssg-snippet-body-end
    }

    /**
     * 获取媒体文件某个时间的截图
     */
    private void getSnapshot() {
        //.cssg-snippet-body-start:[get-snapshot]
        //存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        //文档位于存储桶中的位置标识符，即对象键
        String cosPath = "exampleobject.mp4";
        // 保存在本地文件夹的路径
        String localPath = "localdownloadpath";
        // 截图的本地文件名
        String fileName = "snapshot.jpg";
        // 截帧的时间，单位 s
        float time = 1;
        GetSnapshotRequest getSnapshotRequest = new GetSnapshotRequest(bucket, cosPath, localPath,
                fileName, time);
        //截图的宽。默认为0
        getSnapshotRequest.setWidth(100);
        //截图的高。默认为0
        getSnapshotRequest.setHeight(100);
        //截图的格式，支持 jpg 和 png，默认 jpg
        getSnapshotRequest.setFormat("jpg");
        //图片旋转方式 auto：按视频旋转信息进行自动旋转 off：不旋转  默认值为 auto
        getSnapshotRequest.setRotate("auto");
        //截帧方式 keyframe：截取指定时间点之前的最近的一个关键帧 exactframe：截取指定时间点的帧 默认值为 exactframe
        getSnapshotRequest.setMode("exactframe");

        cosXmlService.getSnapshotAsync(getSnapshotRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                GetSnapshotResult result = (GetSnapshotResult) cosResult;
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
        //.cssg-snippet-body-end
    }

    @Test
    public void testBucketWebsite() {
        initService();

        // 查询已经开通媒体处理功能的存储桶
        getDescribeMediaBuckets();

        // 获取媒体文件的信息
        getMediaInfo();

        // 获取媒体文件某个时间的截图
        getSnapshot();
        // .cssg-methods-pragma
    }
}
