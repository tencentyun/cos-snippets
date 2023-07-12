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
import com.tencent.cos.xml.model.ci.ai.CreateWordsGeneralizeJobRequest;
import com.tencent.cos.xml.model.ci.ai.CreateWordsGeneralizeJobResult;
import com.tencent.cos.xml.model.ci.ai.DescribeAiQueuesRequest;
import com.tencent.cos.xml.model.ci.ai.DescribeAiQueuesResult;
import com.tencent.cos.xml.model.ci.ai.DescribeWordsGeneralizeJobRequest;
import com.tencent.cos.xml.model.ci.ai.DescribeWordsGeneralizeJobResult;
import com.tencent.cos.xml.model.ci.ai.OpenBucketAiRequest;
import com.tencent.cos.xml.model.ci.ai.OpenBucketAiResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class CiWordsGeneralize {
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
     * 开通AI内容识别服务并生成队列
     */
    private void openBucketAi() {
        //.cssg-snippet-body-start:[open-bucket-ai]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        OpenBucketAiRequest request = new OpenBucketAiRequest(bucket);
        ciService.openBucketAiAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 开通AI内容识别服务并生成队列的结果
                // 详细字段请查看api文档或者SDK源码
                OpenBucketAiResult result = (OpenBucketAiResult) cosResult;
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
     * 查询AI识别队列
     */
    private void describeAiQueues() {
        //.cssg-snippet-body-start:[describe-ai-queues]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        DescribeAiQueuesRequest request = new DescribeAiQueuesRequest(bucket);
        //设置第几页
        request.setPageNumber(1);
        //设置每页个数
        request.setPageSize(10);
        //设置状态
        // Active 表示队列内的作业会被识别服务调度执行
        // Paused 表示队列暂停，作业不再会被识别服务调度执行，队列内的所有作业状态维持在暂停状态，已经处于识别中的任务将继续执行，不受影响
        request.setState("Active");
        ciService.describeAiQueuesAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询AI识别队列的结果
                // 详细字段请查看api文档或者SDK源码
                DescribeAiQueuesResult result = (DescribeAiQueuesResult) cosResult;
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
     * 提交AI分词识别任务
     */
    private void createWordsGeneralizeJobs() {
        //.cssg-snippet-body-start:[create-words-generalize-jobs]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        CreateWordsGeneralizeJobRequest request = new CreateWordsGeneralizeJobRequest(bucket);
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String inputPath = "dir1/input.txt";
        //设置文件在 COS 上的 key
        request.setInputObject(inputPath);
        //设置任务回调地址
        //优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调
        request.setCallBack("no");
        //设置任务回调格式，JSON 或 XML，默认 XML
        request.setCallBackFormat("XML");
        //设置透传用户信息, 可打印的 ASCII 码, 长度不超过1024
        request.setUserData("UserDataasdasjdiop12389712893123");
        //设置任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0
        request.setJobLevel(1);
        //设置ner方式, 默认值DL   可选值：NerBasic或DL
        request.setNerMethod("DL");
        //设置分词粒度, 默认值MIX   可选值：SegBasic或MIX
        request.setSegMethod("MIX");
        ciService.createWordsGeneralizeJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交AI分词识别任务的结果
                // 详细字段请查看api文档或者SDK源码
                CreateWordsGeneralizeJobResult result = (CreateWordsGeneralizeJobResult) cosResult;
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
     * 查询指定的AI分词识别任务
     */
    private void describeWordsGeneralizeJob() {
        //.cssg-snippet-body-start:[describe-words-generalize-job]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        //分词识别任务的jobId（提交分词识别任务结果中获取）
        String jobId = "s3841e6aa0cbd11ed923405b602cab698";
        DescribeWordsGeneralizeJobRequest request = new DescribeWordsGeneralizeJobRequest(
                bucket, jobId);
        ciService.describeWordsGeneralizeJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询指定的分词识别任务的结果
                // 详细字段请查看api文档或者SDK源码
                DescribeWordsGeneralizeJobResult result = (DescribeWordsGeneralizeJobResult) cosResult;
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

        // 开通AI内容识别服务并生成队列
        openBucketAi();

        // 查询AI识别队列
        describeAiQueues();

        // 提交AI分词识别任务
        createWordsGeneralizeJobs();

        // 查询指定的AI分词识别任务
        describeWordsGeneralizeJob();
        // .cssg-methods-pragma
    }
}
