package com.tencent.qcloud.cosxml.cssg;


import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CIService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.media.GetPrivateM3U8Request;
import com.tencent.cos.xml.model.ci.media.GetPrivateM3U8Result;
import com.tencent.cos.xml.model.ci.media.GetWorkflowDetailRequest;
import com.tencent.cos.xml.model.ci.media.GetWorkflowDetailResult;
import com.tencent.cos.xml.model.ci.media.GetWorkflowListRequest;
import com.tencent.cos.xml.model.ci.media.GetWorkflowListResult;
import com.tencent.cos.xml.model.ci.media.SearchMediaQueueRequest;
import com.tencent.cos.xml.model.ci.media.SearchMediaQueueResult;
import com.tencent.cos.xml.model.ci.media.TriggerWorkflowRequest;
import com.tencent.cos.xml.model.ci.media.TriggerWorkflowResult;
import com.tencent.cos.xml.model.ci.media.UpdateMediaQueue;
import com.tencent.cos.xml.model.ci.media.UpdateMediaQueueRequest;
import com.tencent.cos.xml.model.ci.media.UpdateMediaQueueResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class CiMedia {
    private Context context;
    private CIService ciService;

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

    private void initService() {
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-guangzhou";

        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();

        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        ciService = new CIService(context, serviceConfig,
                new ServerCredentialProvider());
    }


    /**
     * 获取私有 m3u8
     */
    private void getPrivateM3U8() {
        //.cssg-snippet-body-start:[post-video-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String objectKey = "dir1/playlist.m3u8";
        GetPrivateM3U8Request request = new GetPrivateM3U8Request(bucket, objectKey);
        // 私有 ts 资源 url 下载凭证的相对有效期，单位为秒，范围为[3600, 43200]
        request.expires = "5000";
        ciService.getPrivateM3U8Async(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                GetPrivateM3U8Result result = (GetPrivateM3U8Result) cosResult;
                // GetPrivateM3U8的结果
                String m3u8Response = result.response;
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
     * 搜索媒体处理队列
     */
    private void searchMediaQueue() {
        //.cssg-snippet-body-start:[get-video-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        SearchMediaQueueRequest request = new SearchMediaQueueRequest(bucket);
        //队列 ID，以“,”符号分割字符串
        request.queueIds="id1,id2,id3";
        //队列状态
        // Active 表示队列内的作业会被媒体处理服务调度执行
        // Paused 表示队列暂停，作业不再会被媒体处理调度执行，队列内的所有作业状态维持在暂停状态，已经执行中的任务不受影响
        request.state = "Active";
        //队列类别
        // CateAll：所有类型
        // Transcoding：媒体处理队列
        // SpeedTranscoding：媒体处理倍速转码队列
        // 默认为 Transcoding
        request.category = "CateAll";
        // 第几页，默认值1
        request.pageNumber = "1";
        // 每页个数，默认值10
        request.pageSize = "10";
        ciService.searchMediaQueueAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 搜索媒体处理队列的结果
                // 详细字段请查看api文档或者SDK源码
                SearchMediaQueueResult result = (SearchMediaQueueResult) cosResult;
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
     * 更新媒体处理队列
     */
    private void updateMediaQueue() {
        //.cssg-snippet-body-start:[get-video-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 要更新的队列id
        String queueId = "p4a17eeea29334bf499b7e20e2fbfd99d";
        UpdateMediaQueueRequest request = new UpdateMediaQueueRequest(bucket, queueId);
        UpdateMediaQueue updateMediaQueue = new UpdateMediaQueue();
        // 队列名称，长度不超过128;是否必传：是;默认值：无;限制：无;
        updateMediaQueue.name = "My-Queue-Media";
        // 队列状态
        // Active 表示队列内的作业会被媒体处理服务调度执行
        // Paused 表示队列暂停，作业不再会被媒体处理调度执行，队列内的所有作业状态维持在暂停状态，已经执行中的任务不受影响;
        // 是否必传：是;默认值：无;限制：无;
        updateMediaQueue.state = "Active";
        // 回调配置
        UpdateMediaQueue.UpdateMediaQueueNotifyConfig notifyConfig = new UpdateMediaQueue.UpdateMediaQueueNotifyConfig();
        // 回调开关，Off/On;是否必传：否;默认值：Off;限制：On/Off;
        notifyConfig.state = "On";
        // 回调类型;是否必传：当 State=On 时，必选;默认值：无;限制：Url 或 TDMQ;
        notifyConfig.type = "Url";
        // 回调地址;是否必传：当 State=On，且 Type=Url 时，必选;默认值：无;限制：不能为内网地址;
        notifyConfig.url = "http://callback.demo.com";
        // 回调事件;是否必传：当 State=On 时，必选;默认值：无;限制：任务完成：TaskFinish；工作流完成：WorkflowFinish;
        notifyConfig.event = "TaskFinish";
        // 回调格式;是否必传：否;默认值：XML;限制：JSON/XML;
        notifyConfig.resultFormat = "JSON";
        updateMediaQueue.notifyConfig = notifyConfig;
        request.setUpdateMediaQueue(updateMediaQueue);
        ciService.updateMediaQueueAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 更新媒体处理队列的结果
                // 详细字段请查看api文档或者SDK源码
                UpdateMediaQueueResult result = (UpdateMediaQueueResult) cosResult;
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
     * 测试工作流
     */
    private void triggerWorkflow() {
        //.cssg-snippet-body-start:[get-video-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 需要触发的工作流 ID
        String workflowId = "we59a9648e62e48ffb25e4b41f3721799";
        // 需要进行工作流处理的对象名称
        String objectKey = "dir1/exampleobject.mp4";
        TriggerWorkflowRequest request = new TriggerWorkflowRequest(bucket, workflowId, objectKey);
        // 存量触发任务名称，支持中文、英文、数字、—和_，长度限制128字符，默认为空
        request.setName("任务名称");
        ciService.triggerWorkflowAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 测试工作流的结果
                // 详细字段请查看api文档或者SDK源码
                TriggerWorkflowResult result = (TriggerWorkflowResult) cosResult;
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
     * 查询工作流
     */
    private void getWorkflowList() {
        //.cssg-snippet-body-start:[get-video-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        GetWorkflowListRequest request = new GetWorkflowListRequest(bucket);
        //工作流 ID，以,符号分割字符串
        request.ids="id1,id2,id3";
        //工作流名称
        request.name = "WorkflowName";
        // 第几页
        request.pageNumber = "1";
        // 每页个数
        request.pageSize = "10";
        ciService.getWorkflowListAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询工作流的结果
                // 详细字段请查看api文档或者SDK源码
                GetWorkflowListResult result = (GetWorkflowListResult) cosResult;
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
     * 获取工作流实例详情
     */
    private void getWorkflowDetail() {
        //.cssg-snippet-body-start:[get-video-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 工作流ID
        String runId = "i166ee19017b011eda8a5525400c540df";
        GetWorkflowDetailRequest request = new GetWorkflowDetailRequest(bucket, runId);
        ciService.getWorkflowDetailAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 获取工作流实例详情的结果
                // 详细字段请查看api文档或者SDK源码
                GetWorkflowDetailResult result = (GetWorkflowDetailResult) cosResult;
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
    public void testCiMedia() {
        initService();

        // 获取私有 m3u8
        getPrivateM3U8();

        // 搜索媒体处理队列
        searchMediaQueue();

        // 更新媒体处理队列
        updateMediaQueue();

        // 测试工作流
        triggerWorkflow();

        // 查询工作流
        getWorkflowList();

        // 获取工作流实例详情
        getWorkflowDetail();
        // .cssg-methods-pragma
    }
}
