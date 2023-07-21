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
import com.tencent.cos.xml.model.ci.common.DigitalWatermark;
import com.tencent.cos.xml.model.ci.common.PicProcess;
import com.tencent.cos.xml.model.ci.media.OperationVideoTag;
import com.tencent.cos.xml.model.ci.media.SubmitAnimationJob;
import com.tencent.cos.xml.model.ci.media.SubmitAnimationJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitAnimationJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitConcatJob;
import com.tencent.cos.xml.model.ci.media.SubmitConcatJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitConcatJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitDigitalWatermarkJob;
import com.tencent.cos.xml.model.ci.media.SubmitDigitalWatermarkJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitDigitalWatermarkJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitExtractDigitalWatermarkJob;
import com.tencent.cos.xml.model.ci.media.SubmitExtractDigitalWatermarkJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitExtractDigitalWatermarkJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitMediaInfoJob;
import com.tencent.cos.xml.model.ci.media.SubmitMediaInfoJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitMediaInfoJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitMediaSegmentJob;
import com.tencent.cos.xml.model.ci.media.SubmitMediaSegmentJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitMediaSegmentJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitPicProcessJob;
import com.tencent.cos.xml.model.ci.media.SubmitPicProcessJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitPicProcessJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitSmartCoverJob;
import com.tencent.cos.xml.model.ci.media.SubmitSmartCoverJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitSmartCoverJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitSnapshotJob;
import com.tencent.cos.xml.model.ci.media.SubmitSnapshotJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitSnapshotJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitTranscodeJob;
import com.tencent.cos.xml.model.ci.media.SubmitTranscodeJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitTranscodeJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitVideoMontageJob;
import com.tencent.cos.xml.model.ci.media.SubmitVideoMontageJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitVideoMontageJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitVideoTagJob;
import com.tencent.cos.xml.model.ci.media.SubmitVideoTagJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitVideoTagJobResult;
import com.tencent.cos.xml.model.ci.media.SubmitVoiceSeparateJob;
import com.tencent.cos.xml.model.ci.media.SubmitVoiceSeparateJobRequest;
import com.tencent.cos.xml.model.ci.media.SubmitVoiceSeparateJobResult;
import com.tencent.cos.xml.model.ci.media.TemplateAnimation;
import com.tencent.cos.xml.model.ci.media.TemplateConcat;
import com.tencent.cos.xml.model.ci.media.TemplateSmartCover;
import com.tencent.cos.xml.model.ci.media.TemplateSnapshot;
import com.tencent.cos.xml.model.ci.media.TemplateTranscode;
import com.tencent.cos.xml.model.ci.media.TemplateVideoMontage;
import com.tencent.cos.xml.model.ci.media.TemplateVoiceSeparate;
import com.tencent.cos.xml.model.ci.media.TemplateWatermark;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

public class CiMediaTask {
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
     * 提交视频截帧任务
     */
    private void submitSnapshotJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitSnapshotJobRequest request = new SubmitSnapshotJobRequest(bucket);
        // 请求实体
        SubmitSnapshotJob submitSnapshotJob = new SubmitSnapshotJob();
        SubmitSnapshotJob.SubmitSnapshotJobInput input = new SubmitSnapshotJob.SubmitSnapshotJobInput();
        // 文件路径
        input.object = object;
        submitSnapshotJob.input = input;
        // 操作配置
        SubmitSnapshotJob.SubmitSnapshotJobOperation operation = new SubmitSnapshotJob.SubmitSnapshotJobOperation();
        //该任务的截帧参数
        TemplateSnapshot.TemplateSnapshotSnapshot snapshot = new TemplateSnapshot.TemplateSnapshotSnapshot();
        // 截图数量;是否必传：是;默认值：无;限制：(0 10000];
        snapshot.count = "3";
        operation.snapshot = snapshot;
        // 输出配置
        SubmitSnapshotJob.SubmitSnapshotJobOutput output = new SubmitSnapshotJob.SubmitSnapshotJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 结果文件的名字。当有多个输出文件时必须包含 ${number} 通配符;是否必传：否;
        output.object = outputResultPath+"video_snapshot-${number}.jpg";
        // 雪碧图的名字。当有多个输出文件时必须包含 ${number} 通配符。仅支持 jpg 格式;是否必传：否;
        output.spriteObject = outputResultPath+"video_sprite-${number}.jpg";
        operation.output = output;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        // 透传用户信息, 可打印的 ASCII 码, 长度不超过1024;是否必传：否;
        operation.userData = "userData";
        submitSnapshotJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitSnapshotJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitSnapshotJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitSnapshotJob.callBack = "http://callback.demo.com";
        // 更多配置请查看api文档或者SDK源码
        request.setSubmitSnapshotJob(submitSnapshotJob);
        ciService.submitSnapshotJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交视频截帧任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitSnapshotJobResult result = (SubmitSnapshotJobResult) cosResult;
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

    /**
     * 提交音视频转码任务
     */
    private void submitTranscodeJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitTranscodeJobRequest request = new SubmitTranscodeJobRequest(bucket);
        // 请求实体
        SubmitTranscodeJob submitTranscodeJob = new SubmitTranscodeJob();
        SubmitTranscodeJob.SubmitTranscodeJobInput input = new SubmitTranscodeJob.SubmitTranscodeJobInput();
        // 文件路径
        input.object = object;
        submitTranscodeJob.input = input;
        // 输出配置
        SubmitTranscodeJob.SubmitTranscodeJobOutput output = new SubmitTranscodeJob.SubmitTranscodeJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果的文件名;是否必传：是;
        output.object = outputResultPath+"video_transcode.${ext}";
        // 操作配置
        SubmitTranscodeJob.SubmitTranscodeJobOperation operation = new SubmitTranscodeJob.SubmitTranscodeJobOperation();
        // 转码模板id
//        operation.templateId = "t1460606b9752148c4ab182f55163ba7cd";
        ArrayList<String> watermarkTemplateId = new ArrayList<>();
        SubmitTranscodeJob.SubmitTranscodeJobTranscode transcode = new SubmitTranscodeJob.SubmitTranscodeJobTranscode();
        TemplateTranscode.TemplateTranscodeContainer container = new TemplateTranscode.TemplateTranscodeContainer();
        container.format = "avi";
        transcode.container = container;
        operation.transcode = transcode;
        watermarkTemplateId.add("t1318c5f428d474afba1797f84091cbe22");
        watermarkTemplateId.add("t1318c5f428d474afba1797f84091cbe23");
        watermarkTemplateId.add("t1318c5f428d474afba1797f84091cbe24");
        // 水印模板 ID，可以传多个水印模板 ID，最多传3个。;是否必传：否;
//        operation.watermarkTemplateId = watermarkTemplateId;
        List<TemplateWatermark.Watermark> watermarks = new ArrayList<>();
        TemplateWatermark.TemplateWatermarkText watermarkText = new TemplateWatermark.TemplateWatermarkText();
        // 字体大小;是否必传：是;默认值：无;限制：值范围：[5 100]，单位 px;
        watermarkText.fontSize = "10";
        // 字体类型;是否必传：是;默认值：无;
        watermarkText.fontType = "simfang.ttf";
        // 字体颜色;是否必传：是;默认值：无;限制：格式：0xRRGGBB;
        watermarkText.fontColor = "0x000000";
        //透明度;是否必传：是;默认值：无;限制：值范围：[1 100]，单位%;
        watermarkText.transparency = "30";
        // 水印内容;是否必传：是;默认值：无;限制：长度不超过64个字符，仅支持中文、英文、数字、_、-和*;
        watermarkText.text = "水印内容";
        TemplateWatermark.Watermark watermark1 = new TemplateWatermark.Watermark();
        // 水印类型;是否必传：是;默认值：无;限制：Text：文字水印、 Image：图片水印;
        watermark1.type = "Text";
        // 基准位置;是否必传：是;默认值：无;限制：TopRight、TopLeft、BottomRight、BottomLeft、Left、Right、Top、Bottom、Center;
        watermark1.pos = "Center";
        // 偏移方式;是否必传：是;默认值：无;限制：Relativity：按比例，Absolute：固定位置;
        watermark1.locMode = "Absolute";
        // 水平偏移;是否必传：是;默认值：无;限制：1. 在图片水印中，如果 Background 为 true，当 locMode 为 Relativity 时，为%，值范围：[-300 0]；当 locMode 为 Absolute 时，为 px，值范围：[-4096 0]。2.  在图片水印中，如果 Background 为 false，当 locMode 为 Relativity 时，为%，值范围：[0 100]；当 locMode 为 Absolute 时，为 px，值范围：[0 4096]。3. 在文字水印中，当 locMode 为 Relativity 时，为%，值范围：[0 100]；当 locMode 为 Absolute 时，为 px，值范围：[0 4096]。4. 当Pos为Top、Bottom和Center时，该参数无效。;
        watermark1.dx = "10";
        // 垂直偏移;是否必传：是;默认值：无;限制：1. 在图片水印中，如果 Background 为 true，当 locMode 为 Relativity 时，为%，值范围：[-300 0]；当 locMode 为 Absolute 时，为 px，值范围：[-4096 0]。2. 在图片水印中，如果 Background 为 false，当 locMode 为 Relativity 时，为%，值范围：[0 100]；当 locMode 为 Absolute 时，为 px，值范围：[0 4096]。3. 在文字水印中，当 locMode 为 Relativity 时，为%，值范围：[0 100]；当 locMode 为 Absolute 时，为 px，值范围：[0 4096]。4. 当Pos为Left、Right和Center时，该参数无效。;
        watermark1.dy = "20";
        // 文本水印节点;是否必传：否;默认值：无;限制：无;
        watermark1.text = watermarkText;
        watermarks.add(watermark1);
        TemplateWatermark.Watermark watermark2 = new TemplateWatermark.Watermark();
        watermark2.type = "Text";
        watermark2.pos = "Center";
        watermark2.locMode = "Absolute";
        watermark2.dx = "20";
        watermark2.dy = "10";
        watermark2.text = watermarkText;
        watermarks.add(watermark2);
        // 水印模板参数，同创建水印模板接口中的 Request.Watermark  ，最多传3个。;是否必传：否;
        operation.watermark = watermarks;
        SubmitTranscodeJob.SubmitTranscodeJobSubtitles subtitles = new SubmitTranscodeJob.SubmitTranscodeJobSubtitles();
        List<SubmitTranscodeJob.SubmitTranscodeJobSubtitle> subtitleList = new ArrayList<>();
        SubmitTranscodeJob.SubmitTranscodeJobSubtitle subtitle1 = new SubmitTranscodeJob.SubmitTranscodeJobSubtitle();
        subtitle1.url = "https://srt.com/media/test1.srt";
        subtitleList.add(subtitle1);
        SubmitTranscodeJob.SubmitTranscodeJobSubtitle subtitle2 = new SubmitTranscodeJob.SubmitTranscodeJobSubtitle();
        subtitle2.url = "https://srt.com/media/test2.srt";
        subtitleList.add(subtitle2);
        subtitles.subtitle = subtitleList;
        // 字幕参数, H265、AV1编码和非mkv封装 暂不支持该参数;是否必传：否;
        operation.subtitles = subtitles;
        operation.output = output;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        // 透传用户信息, 可打印的 ASCII 码, 长度不超过1024;是否必传：否;
        operation.userData = "userData";
        submitTranscodeJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitTranscodeJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitTranscodeJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitTranscodeJob.callBack = "http://callback.demo.com";
        // 更多配置请查看api文档或者SDK源码
        request.setSubmitTranscodeJob(submitTranscodeJob);
        ciService.submitTranscodeJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交音视频转码任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitTranscodeJobResult result = (SubmitTranscodeJobResult) cosResult;
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

    /**
     * 提交视频转动图任务
     */
    private void submitAnimationJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitAnimationJobRequest request = new SubmitAnimationJobRequest(bucket);
        SubmitAnimationJob submitAnimationJob = new SubmitAnimationJob();
        SubmitAnimationJob.SubmitAnimationJobInput input = new SubmitAnimationJob.SubmitAnimationJobInput();
        // 文件路径
        input.object = object;
        submitAnimationJob.input = input;
        SubmitAnimationJob.SubmitAnimationJobOutput output = new SubmitAnimationJob.SubmitAnimationJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果的文件名;是否必传：是;
        output.object = outputResultPath+"video_animation.${ext}";
        // 操作配置
        SubmitAnimationJob.SubmitAnimationJobOperation operation = new SubmitAnimationJob.SubmitAnimationJobOperation();
        operation.output = output;
        SubmitAnimationJob.SubmitAnimationJobAnimation animation = new SubmitAnimationJob.SubmitAnimationJobAnimation();
        TemplateAnimation.TemplateAnimationContainer container = new TemplateAnimation.TemplateAnimationContainer();
        // 封装格式：gif，hgif，webp  hgif 为高质量 gif，即清晰度比较高的 gif 格式图;是否必传：是;
        container.format = "gif";
        TemplateAnimation.TemplateAnimationVideo video = new TemplateAnimation.TemplateAnimationVideo();
        // 编解码格式;是否必传：是;默认值：无;限制：gif, webp;
        video.codec = "gif";
        // 宽;是否必传：否;默认值：视频原始宽度;限制：值范围：[128，4096]单位：px若只设置 Width 时，按照视频原始比例计算 Height;
        video.width = "300";
        // 高;是否必传：否;默认值：视频原始高度;限制：值范围：[128，4096]单位：px若只设置 Height 时，按照视频原始比例计算 Width;
        video.height = "200";
        // 帧率;是否必传：否;默认值：视频原始帧率;限制：值范围���(0，60]单位：fps如果不设置，那么播放速度按照原来的时间戳。这里设置 fps 为动图的播放帧率;
        video.fps = "15";
        // 动图只保留关键帧 。若 AnimateOnlyKeepKeyFrame 设置为 true 时，则不考虑 AnimateTimeIntervalOfFrame、AnimateFramesPerSecond；若 AnimateOnlyKeepKeyFrame 设置为 false 时，则必须填写AnimateTimeIntervalOfFrame 或 AnimateFramesPerSecond;是否必传：否;默认值：false;限制：true、false动图保留关键帧参数优先级：AnimateFramesPerSecond > AnimateOnlyKeepKeyFrame > AnimateTimeIntervalOfFrame;
        video.animateOnlyKeepKeyFrame = "true";
        TemplateAnimation.TemplateAnimationTimeInterval timeInterval = new TemplateAnimation.TemplateAnimationTimeInterval();
        // 开始时间;是否必传：否;默认值：0;限制： [0 视频时长] 单位为秒 支持 float 格式，执行精度精确到毫秒;
        timeInterval.start = "0";
        // 持续时间;是否必传：否;默认值：视频时长;限制： [0 视频时长] 单位为秒 支持 float 格式，执行精度精确到毫秒;
        timeInterval.duration = "60";
        // 同创建动图模板接口中的 Request.TimeInterval;是否必传：否;
        animation.timeInterval = timeInterval;
        // 同创建动图模板接口中的 Request.Video;是否必传：否;
        animation.video = video;
        // 同创建动图模板接口中的 Request.Container;是否必传：否;
        animation.container = container;
        // 该任务的参数
        operation.animation = animation;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        // 透传用户信息, 可打印的 ASCII 码, 长度不超过1024;是否必传：否;
        operation.userData = "userData";
        submitAnimationJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitAnimationJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitAnimationJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitAnimationJob.callBack = "http://callback.demo.com";
        // 更多配置请查看api文档或者SDK源码
        request.setSubmitAnimationJob(submitAnimationJob);
        ciService.submitAnimationJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交视频转动图任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitAnimationJobResult result = (SubmitAnimationJobResult) cosResult;
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

    /**
     * 提交音视频拼接任务
     */
    private void submitConcatJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitConcatJobRequest request = new SubmitConcatJobRequest(bucket);
        SubmitConcatJob submitConcatJob = new SubmitConcatJob();
        SubmitConcatJob.SubmitConcatJobInput input = new SubmitConcatJob.SubmitConcatJobInput();
        // 文件路径
        input.object = object;
        submitConcatJob.input = input;
        SubmitConcatJob.SubmitConcatJobOutput output = new SubmitConcatJob.SubmitConcatJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果的文件名;是否必传：是;
        output.object = outputResultPath+"video_concat.${ext}";
        // 操作配置
        SubmitConcatJob.SubmitConcatJobOperation operation = new SubmitConcatJob.SubmitConcatJobOperation();
        operation.output = output;
        SubmitConcatJob.SubmitConcatJobConcatTemplate concatTemplate = new SubmitConcatJob.SubmitConcatJobConcatTemplate();
        TemplateConcat.TemplateConcatContainer container = new TemplateConcat.TemplateConcatContainer();
        // 封装格式：mp4，flv，hls，ts, mp3, aac;是否必传：是;
        container.format = "flv";
        concatTemplate.container = container;
        operation.concatTemplate = concatTemplate;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitConcatJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitConcatJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitConcatJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitConcatJob.callBack = "http://callback.demo.com";
        request.setSubmitConcatJob(submitConcatJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitConcatJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交音视频拼接任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitConcatJobResult result = (SubmitConcatJobResult) cosResult;
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

    /**
     * 提交智能封面任务
     */
    private void submitSmartCoverJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitSmartCoverJobRequest request = new SubmitSmartCoverJobRequest(bucket);
        SubmitSmartCoverJob submitSmartCoverJob = new SubmitSmartCoverJob();
        SubmitSmartCoverJob.SubmitSmartCoverJobInput input = new SubmitSmartCoverJob.SubmitSmartCoverJobInput();
        // 文件路径
        input.object = object;
        submitSmartCoverJob.input = input;
        SubmitSmartCoverJob.SubmitSmartCoverJobOutput output = new SubmitSmartCoverJob.SubmitSmartCoverJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果的文件名。当有多个输出文件时必须包含 ${number} 通配符。;是否必传：是;
        output.object = outputResultPath+"smartcover-${number}.png";
        // 操作配置
        SubmitSmartCoverJob.SubmitSmartCoverJobOperation operation = new SubmitSmartCoverJob.SubmitSmartCoverJobOperation();
        operation.output = output;
        TemplateSmartCover.TemplateSmartCoverSmartCover smartCover = new TemplateSmartCover.TemplateSmartCoverSmartCover();
        // 图片格式;是否必传：否;默认值：jpg;限制：jpg、png  、webp;
        smartCover.format = "png";
        operation.smartCover = smartCover;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitSmartCoverJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitSmartCoverJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitSmartCoverJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitSmartCoverJob.callBack = "http://callback.demo.com";
        request.setSubmitSmartCoverJob(submitSmartCoverJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitSmartCoverJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交智能封面任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitSmartCoverJobResult result = (SubmitSmartCoverJobResult) cosResult;
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

    /**
     * 提交精彩集锦任务
     */
    private void submitVideoMontageJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitVideoMontageJobRequest request = new SubmitVideoMontageJobRequest(bucket);
        SubmitVideoMontageJob submitVideoMontageJob = new SubmitVideoMontageJob();
        SubmitVideoMontageJob.SubmitVideoMontageJobInput input = new SubmitVideoMontageJob.SubmitVideoMontageJobInput();
        // 文件路径
        input.object = object;
        submitVideoMontageJob.input = input;
        SubmitVideoMontageJob.SubmitVideoMontageJobOutput output = new SubmitVideoMontageJob.SubmitVideoMontageJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果的文件名。
        output.object = outputResultPath+"video_montage.${ext}";
        // 操作配置
        SubmitVideoMontageJob.SubmitVideoMontageJobOperation operation = new SubmitVideoMontageJob.SubmitVideoMontageJobOperation();
        operation.output = output;
        SubmitVideoMontageJob.SubmitVideoMontageJobVideoMontage videoMontage = new SubmitVideoMontageJob.SubmitVideoMontageJobVideoMontage();
        TemplateVideoMontage.TemplateVideoMontageContainer container = new TemplateVideoMontage.TemplateVideoMontageContainer();
        // 封装格式: mp4、flv、hls、ts、mkv;是否必传：是;
        container.format = "mp4";
        videoMontage.container = container;
        operation.videoMontage = videoMontage;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitVideoMontageJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitVideoMontageJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitVideoMontageJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitVideoMontageJob.callBack = "http://callback.demo.com";
        request.setSubmitVideoMontageJob(submitVideoMontageJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitVideoMontageJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交精彩集锦任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitVideoMontageJobResult result = (SubmitVideoMontageJobResult) cosResult;
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

    /**
     * 提交人声分离任务
     */
    private void submitVoiceSeparateJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitVoiceSeparateJobRequest request = new SubmitVoiceSeparateJobRequest(bucket);
        SubmitVoiceSeparateJob submitVoiceSeparateJob = new SubmitVoiceSeparateJob();
        SubmitVoiceSeparateJob.SubmitVoiceSeparateJobInput input = new SubmitVoiceSeparateJob.SubmitVoiceSeparateJobInput();
        // 文件路径
        input.object = object;
        submitVoiceSeparateJob.input = input;
        SubmitVoiceSeparateJob.SubmitVoiceSeparateJobOutput output = new SubmitVoiceSeparateJob.SubmitVoiceSeparateJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 背景音结果文件名，不能与 AuObject 同时为空;是否必传：否;
        output.object = outputResultPath+"video_backgroud.${ext}";
        // 人声结果文件名，不能与 Object 同时为空;是否必传：否;
        output.auObject = outputResultPath+"video_audio.${ext}";
        SubmitVoiceSeparateJob.SubmitVoiceSeparateJobOperation operation = new SubmitVoiceSeparateJob.SubmitVoiceSeparateJobOperation();
        operation.output = output;
        SubmitVoiceSeparateJob.VoiceSeparate voiceSeparate = new SubmitVoiceSeparateJob.VoiceSeparate();
        // 同创建人声分离模板接口中的 Request.AudioMode;是否必传：否;
        voiceSeparate.audioMode = "IsAudio";
        TemplateVoiceSeparate.AudioConfig audioConfig = new TemplateVoiceSeparate.AudioConfig();
        // 编解码格式;是否必传：否;默认值：aac;限制：取值 aac、mp3、flac、amr;
        audioConfig.codec = "aac";
        // 采样率;是否必传：否;默认值：44100;限制：1. 单位：Hz2. 可选 8000、11025、22050、32000、44100、48000、960003. 当 Codec 设置为 aac/flac 时，不支持80004. 当 Codec 设置为 mp3 时，不支持8000和960005. 5. 当 Codec 设置为 amr 时，只支持8000;
        audioConfig.samplerate = "44100";
        // 原始音频码率;是否必传：否;默认值：无;限制：1. 单位：Kbps2. 值范围：[8，1000];
        audioConfig.bitrate = "128";
        // 声道数;是否必传：否;默认值：无;限制：1. 当 Codec 设置为 aac/flac，支持1、2、4、5、6、82. 当 Codec 设置为 mp3，支持1、2 3. 当 Codec 设置为 amr，只支持1;
        audioConfig.channels = "4";
        voiceSeparate.audioConfig = audioConfig;
        operation.voiceSeparate = voiceSeparate;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitVoiceSeparateJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitVoiceSeparateJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitVoiceSeparateJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitVoiceSeparateJob.callBack = "http://callback.demo.com";
        request.setSubmitVoiceSeparateJob(submitVoiceSeparateJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitVoiceSeparateJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交人声分离任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitVoiceSeparateJobResult result = (SubmitVoiceSeparateJobResult) cosResult;
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

    /**
     * 提交数字水印任务
     */
    private void submitDigitalWatermarkJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitDigitalWatermarkJobRequest request = new SubmitDigitalWatermarkJobRequest(bucket);
        SubmitDigitalWatermarkJob submitDigitalWatermarkJob = new SubmitDigitalWatermarkJob();
        SubmitDigitalWatermarkJob.SubmitDigitalWatermarkJobInput input = new SubmitDigitalWatermarkJob.SubmitDigitalWatermarkJobInput();
        // 文件路径
        input.object = object;
        submitDigitalWatermarkJob.input = input;
        SubmitDigitalWatermarkJob.SubmitDigitalWatermarkJobOutput output = new SubmitDigitalWatermarkJob.SubmitDigitalWatermarkJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果文件
        output.object = outputResultPath+"DigitalWatermark.mp4";
        SubmitDigitalWatermarkJob.SubmitDigitalWatermarkJobOperation operation = new SubmitDigitalWatermarkJob.SubmitDigitalWatermarkJobOperation();
        operation.output = output;
        DigitalWatermark digitalWatermark = new DigitalWatermark();
        // 嵌入数字水印的水印信息
        // * 长度不超过64个字符，仅支持中文、英文、数字、_、-和*
        digitalWatermark.message = "DigitalWatermarkTest";
        operation.digitalWatermark = digitalWatermark;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitDigitalWatermarkJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitDigitalWatermarkJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitDigitalWatermarkJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitDigitalWatermarkJob.callBack = "http://callback.demo.com";
        request.setSubmitDigitalWatermarkJob(submitDigitalWatermarkJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitDigitalWatermarkJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交数字水印任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitDigitalWatermarkJobResult result = (SubmitDigitalWatermarkJobResult) cosResult;
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

    /**
     * 提交提取数字水印任务
     */
    private void submitExtractDigitalWatermarkJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        SubmitExtractDigitalWatermarkJobRequest request = new SubmitExtractDigitalWatermarkJobRequest(bucket);
        SubmitExtractDigitalWatermarkJob submitExtractDigitalWatermarkJob = new SubmitExtractDigitalWatermarkJob();
        SubmitExtractDigitalWatermarkJob.SubmitExtractDigitalWatermarkJobInput input = new SubmitExtractDigitalWatermarkJob.SubmitExtractDigitalWatermarkJobInput();
        // 文件路径
        input.object = object;
        submitExtractDigitalWatermarkJob.input = input;
        SubmitExtractDigitalWatermarkJob.SubmitExtractDigitalWatermarkJobOperation operation = new SubmitExtractDigitalWatermarkJob.SubmitExtractDigitalWatermarkJobOperation();
        SubmitExtractDigitalWatermarkJob.SubmitExtractDigitalWatermarkJobExtractDigitalWatermark extractDigitalWatermark = new SubmitExtractDigitalWatermarkJob.SubmitExtractDigitalWatermarkJobExtractDigitalWatermark();
        operation.extractDigitalWatermark = extractDigitalWatermark;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitExtractDigitalWatermarkJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitExtractDigitalWatermarkJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitExtractDigitalWatermarkJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitExtractDigitalWatermarkJob.callBack = "http://callback.demo.com";
        request.setSubmitExtractDigitalWatermarkJob(submitExtractDigitalWatermarkJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitExtractDigitalWatermarkJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交提取数字水印任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitExtractDigitalWatermarkJobResult result = (SubmitExtractDigitalWatermarkJobResult) cosResult;
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

    /**
     * 提交视频标签任务
     */
    private void submitVideoTagJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        SubmitVideoTagJobRequest request = new SubmitVideoTagJobRequest(bucket);
        SubmitVideoTagJob submitVideoTagJob = new SubmitVideoTagJob();
        SubmitVideoTagJob.SubmitVideoTagJobInput input = new SubmitVideoTagJob.SubmitVideoTagJobInput();
        // 文件路径
        input.object = object;
        submitVideoTagJob.input = input;
        SubmitVideoTagJob.SubmitVideoTagJobOperation operation = new SubmitVideoTagJob.SubmitVideoTagJobOperation();
        operation.videoTag = new OperationVideoTag();
        submitVideoTagJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitVideoTagJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitVideoTagJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitVideoTagJob.callBack = "http://callback.demo.com";
        request.setSubmitVideoTagJob(submitVideoTagJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitVideoTagJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交视频标签任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitVideoTagJobResult result = (SubmitVideoTagJobResult) cosResult;
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

    /**
     * 提交图片处理任务
     */
    private void submitPicProcessJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitPicProcessJobRequest request = new SubmitPicProcessJobRequest(bucket);
        SubmitPicProcessJob submitPicProcessJob = new SubmitPicProcessJob();
        SubmitPicProcessJob.SubmitPicProcessJobInput input = new SubmitPicProcessJob.SubmitPicProcessJobInput();
        // 文件路径
        input.object = object;
        submitPicProcessJob.input = input;
        SubmitPicProcessJob.SubmitPicProcessJobOperation operation = new SubmitPicProcessJob.SubmitPicProcessJobOperation();
        SubmitPicProcessJob.SubmitPicProcessJobOutput output = new SubmitPicProcessJob.SubmitPicProcessJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果文件
        output.object = outputResultPath+"PicProcess.jpg";
        operation.output = output;
        PicProcess picProcess = new PicProcess();
        // 是否返回原图信息;是否必传：否;
        picProcess.isPicInfo = true;
        /*
          图片处理规则;是否必传：是;
          1. 基础图片处理参见<a href="https://cloud.tencent.com/document/product/436/44879">基础图片处理</a>文档
          2. 图片压缩参见<a href="https://cloud.tencent.com/document/product/436/60450">图片压缩</a>文档
          3. 盲水印参见<a href="https://cloud.tencent.com/document/product/436/46782">盲水印</a>文档
         */
        picProcess.processRule = "imageMogr2/rotate/90";
        operation.picProcess = picProcess;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitPicProcessJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitPicProcessJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitPicProcessJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitPicProcessJob.callBack = "http://callback.demo.com";
        request.setSubmitPicProcessJob(submitPicProcessJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitPicProcessJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交图片处理任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitPicProcessJobResult result = (SubmitPicProcessJobResult) cosResult;
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

    /**
     * 提交音视频转封装任务
     */
    private void submitMediaSegmentJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        // 输出路径文件夹
        String outputResultPath = "media/job_result/";
        SubmitMediaSegmentJobRequest request = new SubmitMediaSegmentJobRequest(bucket);
        SubmitMediaSegmentJob submitMediaSegmentJob = new SubmitMediaSegmentJob();
        SubmitMediaSegmentJob.SubmitMediaSegmentJobInput input = new SubmitMediaSegmentJob.SubmitMediaSegmentJobInput();
        // 文件路径
        input.object = object;
        submitMediaSegmentJob.input = input;
        SubmitMediaSegmentJob.SubmitMediaSegmentJobOperation operation = new SubmitMediaSegmentJob.SubmitMediaSegmentJobOperation();
        SubmitMediaSegmentJob.SubmitMediaSegmentJobOutput output = new SubmitMediaSegmentJob.SubmitMediaSegmentJobOutput();
        // 输出存储桶地域
        output.region = "ap-guangzhou";
        // 输出存储桶
        output.bucket = bucket;
        // 输出结果的文件名，如果设置了Duration, 且 Format 不为 HLS 或 m3u8 时，文件名必须包含${number}参数作为自定义转封装后每一小段音/视频流的输出序号;是否必传：是;
        output.object = outputResultPath+"MediaSegment-${number}";
        operation.output = output;
        SubmitMediaSegmentJob.SubmitMediaSegmentJobSegment segment = new SubmitMediaSegmentJob.SubmitMediaSegmentJobSegment();
        // 封装格式;是否必传：是;限制：aac、mp3、flac、mp4、ts、mkv、avi、hls、m3u8;
        segment.format = "mp4";
        // 转封装时长，单位：秒;是否必传：否;限制：不小于5的整数;
        segment.duration = "5";
        SubmitMediaSegmentJob.SubmitMediaSegmentJobHlsEncrypt hlsEncrypt = new SubmitMediaSegmentJob.SubmitMediaSegmentJobHlsEncrypt();
        // 是否开启 HLS 加密;是否必传：否;默认值：false;限制：1. true/false 2. Segment.Format 为 HLS 时支持加密;
        hlsEncrypt.isHlsEncrypt = "true";
        // HLS 加密的 key;是否必传：否;默认值：无;限制：当 IsHlsEncrypt 为 true 时，该参数才有意义;
        hlsEncrypt.uriKey = "test-key";
        segment.hlsEncrypt = hlsEncrypt;
        operation.segment = segment;
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitMediaSegmentJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitMediaSegmentJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitMediaSegmentJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitMediaSegmentJob.callBack = "http://callback.demo.com";
        request.setSubmitMediaSegmentJob(submitMediaSegmentJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitMediaSegmentJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交音视频转封装任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitMediaSegmentJobResult result = (SubmitMediaSegmentJobResult) cosResult;
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

    /**
     * 提交获取媒体信息任务
     */
    private void submitMediaInfoJob() {
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String object = "dir1/exampleobject.mp4";
        SubmitMediaInfoJobRequest request = new SubmitMediaInfoJobRequest(bucket);
        SubmitMediaInfoJob submitMediaInfoJob = new SubmitMediaInfoJob();
        SubmitMediaInfoJob.SubmitMediaInfoJobInput input = new SubmitMediaInfoJob.SubmitMediaInfoJobInput();
        // 文件路径
        input.object = object;
        submitMediaInfoJob.input = input;
        SubmitMediaInfoJob.SubmitMediaInfoJobOperation operation = new SubmitMediaInfoJob.SubmitMediaInfoJobOperation();
        // 任务优先级，级别限制：0 、1 、2 。级别越大任务优先级越高，默认为0;是否必传：否;
        operation.jobLevel = "0";
        submitMediaInfoJob.operation = operation;
        // 任务回调格式，JSON 或 XML，默认 XML，优先级高于队列的回调格式;是否必传：否;
        submitMediaInfoJob.callBackFormat = "XML";
        // 任务回调类型，Url 或 TDMQ，默认 Url，优先级高于队列的回调类型;是否必传：否;
        submitMediaInfoJob.callBackType = "Url";
        // 任务回调地址，优先级高于队列的回调地址。设置为 no 时，表示队列的回调地址不产生回调;是否必传：否;
        submitMediaInfoJob.callBack = "http://callback.demo.com";
        request.setSubmitMediaInfoJob(submitMediaInfoJob);
        // 更多配置请查看api文档或者SDK源码
        ciService.submitMediaInfoJobAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交获取媒体信息任务的结果
                // 详细字段请查看api文档或者SDK源码
                SubmitMediaInfoJobResult result = (SubmitMediaInfoJobResult) cosResult;
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

    @Test
    public void testCiMediaTask() {
        initService();

        // 提交视频截帧任务
        submitSnapshotJob();

        // 提交音视频转码任务
        submitTranscodeJob();

        // 提交视频转动图任务
        submitAnimationJob();

        // 提交音视频拼接任务
        submitConcatJob();

        // 提交智能封面任务
        submitSmartCoverJob();

        // 提交精彩集锦任务
        submitVideoMontageJob();

        // 提交人声分离任务
        submitVoiceSeparateJob();

        // 提交数字水印任务
        submitDigitalWatermarkJob();

        // 提交提取数字水印任务
        submitExtractDigitalWatermarkJob();

        // 提交视频标签任务
        submitVideoTagJob();

        // 提交图片处理任务
        submitPicProcessJob();

        // 提交音视频转封装任务
        submitMediaSegmentJob();

        // 提交获取媒体信息任务
        submitMediaInfoJob();
    }
}
