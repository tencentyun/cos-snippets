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
import com.tencent.cos.xml.model.ci.asr.CreateSpeechJobsRequest;
import com.tencent.cos.xml.model.ci.asr.CreateSpeechJobsResult;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechBucketsRequest;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechBucketsResult;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechJobRequest;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechJobResult;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechJobsRequest;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechJobsResult;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechQueuesRequest;
import com.tencent.cos.xml.model.ci.asr.DescribeSpeechQueuesResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class CiAsr {
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
     * 查询已经开通语音识别功能的存储桶
     */
    private void describeSpeechBuckets() {
        //.cssg-snippet-body-start:[describe-speech-buckets]

        DescribeSpeechBucketsRequest request = new DescribeSpeechBucketsRequest();
        //设置第几页
        request.setPageNumber(1);
        //设置每页个数
        request.setPageSize(10);
        //设置地域信息 以“,”分隔字符串，支持 All、ap-shanghai、ap-beijing
        request.setRegions("All");
        //设置存储桶名称，以“,”分隔，支持多个存储桶，精确搜索
        //request.setBucketNames("examplebucket-1250000000,examplebucket123-1250000000");
        //设置存储桶名称前缀，前缀搜索
        //request.setBucketName("examplebucket");
        ciService.describeSpeechBucketsAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询已经开通语音识别功能的存储桶的结果
                // 详细字段请查看api文档或者SDK源码
                DescribeSpeechBucketsResult result = (DescribeSpeechBucketsResult) cosResult;
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
     * 查询语音识别队列
     */
    private void describeSpeechQueues() {
        //.cssg-snippet-body-start:[describe-speech-queues]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        DescribeSpeechQueuesRequest request = new DescribeSpeechQueuesRequest(bucket);
        //设置第几页
        request.setPageNumber(1);
        //设置每页个数
        request.setPageSize(10);
        //设置状态
        // Active 表示队列内的作业会被语音识别服务调度执行
        // Paused 表示队列暂停，作业不再会被语音识别服务调度执行，队列内的所有作业状态维持在暂停状态，已经处于识别中的任务将继续执行，不受影响
        request.setState("Active");
        ciService.describeSpeechQueuesAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询语音识别队列的结果
                // 详细字段请查看api文档或者SDK源码
                DescribeSpeechQueuesResult result = (DescribeSpeechQueuesResult) cosResult;
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
     * 提交语音识别任务
     */
    private void createSpeechJobs() {
        //.cssg-snippet-body-start:[create-speech-jobs]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        CreateSpeechJobsRequest request = new CreateSpeechJobsRequest(bucket);
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String inputPath = "dir1/input.m4a";
        //设置语音文件在 COS 上的 key
        request.setInputObject(inputPath);
        //输出cos路径
        String outputPath = "dir1/putput.txt";
        //设置结果输出地址
        request.setOutput("ap-guangzhou", bucket, outputPath);
        //设置引擎模型类型。
        //电话场景：
        //• 8k_zh：电话 8k 中文普通话通用（可用于双声道音频）；
        //• 8k_zh_s：电话 8k 中文普通话话者分离（仅适用于单声道音频）；
        //非电话场景：
        //• 16k_zh：16k 中文普通话通用；
        //• 16k_zh_video：16k 音视频领域；
        //• 16k_en：16k 英语；
        //• 16k_ca：16k 粤语。
        request.setEngineModelType("8k_zh");
        //设置语音声道数。1：单声道；2：双声道（仅支持 8k_zh 引擎模型）
        request.setChannelNum(2);
        //设置识别结果返回形式。
        // 0： 识别结果文本(含分段时间戳)； 1：仅支持16k中文引擎，含识别结果详情(词时间戳列表，一般用于生成字幕场景)
        request.setResTextFormat(0);

        ciService.createSpeechJobsAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交语音识别任务的结果
                // 详细字段请查看api文档或者SDK源码
                CreateSpeechJobsResult result = (CreateSpeechJobsResult) cosResult;
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
     * 查询指定的语音识别任务
     */
    private void describeSpeechJob() {
        //.cssg-snippet-body-start:[describe-speech-job]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        //语音识别任务的jobId（提交语音识别任务结果中获取）
        String jobId = "s3841e6aa0cbd11ed923405b602cab698";
        DescribeSpeechJobRequest request = new DescribeSpeechJobRequest(bucket, jobId);
        ciService.describeSpeechJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询指定的语音识别任务的结果
                // 详细字段请查看api文档或者SDK源码
                DescribeSpeechJobResult result = (DescribeSpeechJobResult) cosResult;
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
     * 拉取符合条件的语音识别任务
     */
    private void describeSpeechJobs() {
        //.cssg-snippet-body-start:[describe-speech-jobs]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        DescribeSpeechJobsRequest request = new DescribeSpeechJobsRequest(bucket);
        //Desc 或者 Asc。默认为 Desc。
        request.setOrderByTime("Desc");
        //请求的上下文，用于翻页。上次返回的值。
        request.setNextToken("NextToken");
        //拉取的最大任务数。默认为10。最大为100。
        request.setSize(50);
        //拉取该状态的任务，以,分割，支持多状态：All、Submitted、Running、Success、Failed、Pause、Cancel。默认为 All。
        request.setStates("All");
        //拉取创建时间大于该时间的任务。格式为：%Y-%m-%dT%H:%m:%S%z
        request.setStartCreationTime("%Y-%m-%dT%H:%m:%S%z");
        //拉取创建时间小于该时间的任务。格式为：%Y-%m-%dT%H:%m:%S%z
        request.setEndCreationTime("%Y-%m-%dT%H:%m:%S%z");

        ciService.describeSpeechJobsAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 拉取符合条件的语音识别任务的结果
                // 详细字段请查看api文档或者SDK源码
                DescribeSpeechJobsResult result = (DescribeSpeechJobsResult) cosResult;
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

        // 查询已经开通语音识别功能的存储桶
        describeSpeechBuckets();

        // 查询语音识别队列
        describeSpeechQueues();

        // 提交语音识别任务
        createSpeechJobs();

        // 查询指定的语音识别任务
        describeSpeechJob();

        // 拉取符合条件的语音识别任务
        describeSpeechJobs();
        // .cssg-methods-pragma
    }
}
