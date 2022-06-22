package com.tencent.qcloud.cosxml.cssg;


import android.content.Context;
import android.support.test.InstrumentationRegistry;
import android.util.Base64;

import com.tencent.cos.xml.CIService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.GetVideoAuditRequest;
import com.tencent.cos.xml.model.ci.GetVideoAuditResult;
import com.tencent.cos.xml.model.ci.PostAudioAuditRequest;
import com.tencent.cos.xml.model.ci.PostAuditResult;
import com.tencent.cos.xml.model.ci.PostDocumentAuditRequest;
import com.tencent.cos.xml.model.ci.PostTextAuditRequest;
import com.tencent.cos.xml.model.ci.PostVideoAuditRequest;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

import java.nio.charset.Charset;

public class CiAudit {
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
     * 图片批量审核
     */
    private void postImagesAudit() {
        //.cssg-snippet-body-start:[post-images-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String cosPath1 = "dir1/exampleobject1.jpg";
        String cosPath2 = "dir1/exampleobject2.jpg";
        //图片的链接地址,Object 和 Url 只能选择其中一种
        String imageUrl = "https://myqcloud.com/%205image.jpg";
        PostImagesAuditRequest request = new PostImagesAuditRequest(bucket);
        PostImagesAudit.ImagesAuditInput image1 = new PostImagesAudit.ImagesAuditInput();
        image1.object = cosPath1;
        //设置原始内容，长度限制为512字节，该字段会在响应中原样返回
        image1.dataId = "DataId1";
        //截帧频率，GIF 图检测专用，默认值为5，表示从第一帧（包含）开始每隔5帧截取一帧
        image1.interval = 2;
        //最大截帧数量，GIF 图检测专用，默认值为5，表示只截取 GIF 的5帧图片进行审核，必须大于0
        image1.maxFrames = 5;
        PostImagesAudit.ImagesAuditInput image2 = new PostImagesAudit.ImagesAuditInput();
        image2.object = cosPath2;
        image2.dataId = "DataId2";
        image2.interval = 2;
        image2.maxFrames = 5;
        PostImagesAudit.ImagesAuditInput image3 = new PostImagesAudit.ImagesAuditInput();
        image3.url = imageUrl;
        image3.dataId = "DataId3";
        image3.interval = 2;
        image3.maxFrames = 5;
        request.addImage(image1);
        request.addImage(image2);
        request.addImage(image3);
        //审核的场景类型，有效值：Porn（涉黄）、Ads（广告），可以传入多种类型，不同类型以,分隔，例如：Porn,Ads。
        request.setDetectType("Porn,Ads");

        ciService.postImagesAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 图片批量审核的结果
                // 详细字段请查看api文档或者SDK源码
                PostImagesAuditResult result = (PostImagesAuditResult) cosResult;
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
     * 查询图片审核任务结果
     */
    private void getImageAudit() {
        //.cssg-snippet-body-start:[get-image-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 审核任务的 ID
        String jobId = "iab1ca9fc8a3ed11ea834c525400863904";
        GetImageAuditRequest request = new GetImageAuditRequest(bucket, jobId);
        ciService.getImageAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询图片审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                GetImageAuditResult result = (GetImageAuditResult) cosResult;
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
     * 提交视频审核任务
     */
    private void postVideoAudit() {
        //.cssg-snippet-body-start:[post-video-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String cosPath = "dir1/exampleobject.mp4";
        //视频的链接地址,Object 和 Url 只能选择其中一种
        String url = "https://myqcloud.com/%205video.mp4";
        PostVideoAuditRequest request = new PostVideoAuditRequest(bucket);
        request.setObject(cosPath);
        request.setUrl(url);
        //设置原始内容，长度限制为512字节，该字段会在响应中原样返回
        request.setDataId("DataId");
        //回调地址，以http://或者https://开头的地址。
        request.setCallback("https://github.com");
        //回调内容的结构，有效值：Simple（回调内容包含基本信息）、Detail（回调内容包含详细信息）。默认为 Simple。
        request.setCallbackVersion("Detail");
        //视频截帧数量，范围为(0, 10000]。
        request.setCount(3);
        //视频截帧频率，范围为(0, 60]，单位为秒，支持 float 格式，执行精度精确到毫秒。
        request.setTimeInterval(10);
        //审核的场景类型，有效值：Porn（涉黄）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Ads。
        request.setDetectType("Porn,Ads");
        //用于指定是否审核视频声音，当值为0时：表示只审核视频画面截图；值为1时：表示同时审核视频画面截图和视频声音。默认值为0。
        request.setDetectContent(1);

        ciService.postVideoAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交视频审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                PostAuditResult result = (PostAuditResult) cosResult;
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
     * 查询视频审核任务结果
     */
    private void getVideoAudit() {
        //.cssg-snippet-body-start:[get-video-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 审核任务的 ID
        String jobId = "iab1ca9fc8a3ed11ea834c525400863904";
        GetVideoAuditRequest request = new GetVideoAuditRequest(bucket, jobId);
        ciService.getVideoAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询视频审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                GetVideoAuditResult result = (GetVideoAuditResult) cosResult;
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
     * 提交音频审核任务
     */
    private void postAudioAudit() {
        //.cssg-snippet-body-start:[post-audio-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String cosPath = "dir1/exampleobject.mp3";
        //音频的链接地址,Object 和 Url 只能选择其中一种
        String url = "https://myqcloud.com/%205Audio.mp3";
        PostAudioAuditRequest request = new PostAudioAuditRequest(bucket);
        request.setObject(cosPath);
        request.setUrl(url);
        //设置原始内容，长度限制为512字节，该字段会在响应中原样返回
        request.setDataId("DataId");
        //回调地址，以http://或者https://开头的地址。
        request.setCallback("https://github.com");
        //回调内容的结构，有效值：Simple（回调内容包含基本信息）、Detail（回调内容包含详细信息）。默认为 Simple。
        request.setCallbackVersion("Detail");
        //审核的场景类型，有效值：Porn（涉黄）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Ads。
        request.setDetectType("Porn,Ads");

        ciService.postAudioAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交音频审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                PostAuditResult result = (PostAuditResult) cosResult;
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
     * 查询音频审核任务结果
     */
    private void getAudioAudit() {
        //.cssg-snippet-body-start:[get-audio-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 审核任务的 ID
        String jobId = "iab1ca9fc8a3ed11ea834c525400863904";
        GetAudioAuditRequest request = new GetAudioAuditRequest(bucket, jobId);
        ciService.getAudioAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询音频审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                GetAudioAuditResult result = (GetAudioAuditResult) cosResult;
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
     * 提交文本审核任务
     */
    private void postTextAudit() {
        //.cssg-snippet-body-start:[post-text-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String cosPath = "dir1/exampleobject.txt";
        //文本的链接地址,Object 和 Url 只能选择其中一种
        String url = "https://myqcloud.com/%205text.txt";
        //当传入的内容为纯文本信息，需要先经过 base64 编码，文本编码前的原文长度不能超过10000个 utf8 编码字符。若超出长度限制，接口将会报错。
        String content = Base64.encodeToString("测试文本".getBytes(Charset.forName("UTF-8")), Base64.NO_WRAP);
        PostTextAuditRequest request = new PostTextAuditRequest(bucket);
        request.setObject(cosPath);
        request.setUrl(url);
        request.setContent(content);
        //设置原始内容，长度限制为512字节，该字段会在响应中原样返回
        request.setDataId("DataId");
        //回调地址，以http://或者https://开头的地址。
        request.setCallback("https://github.com");
        //回调内容的结构，有效值：Simple（回调内容包含基本信息）、Detail（回调内容包含详细信息）。默认为 Simple。
        request.setCallbackVersion("Detail");
        //审核的场景类型，有效值：Porn（涉黄）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Ads。
        request.setDetectType("Porn,Ads");

        ciService.postTextAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交文本审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                TextAuditResult result = (TextAuditResult) cosResult;
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
     * 查询文本审核任务结果
     */
    private void getTextAudit() {
        //.cssg-snippet-body-start:[get-text-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 审核任务的 ID
        String jobId = "iab1ca9fc8a3ed11ea834c525400863904";
        GetTextAuditRequest request = new GetTextAuditRequest(bucket, jobId);
        ciService.getTextAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询文本审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                TextAuditResult result = (TextAuditResult) cosResult;
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
     * 提交文档审核任务
     */
    private void postDocumentAudit() {
        //.cssg-snippet-body-start:[post-document-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        String cosPath = "dir1/exampleobject.pdf";
        //文档的链接地址,Object 和 Url 只能选择其中一种
        String url = "https://myqcloud.com/%205Document.pdf";
        PostDocumentAuditRequest request = new PostDocumentAuditRequest(bucket);
        request.setObject(cosPath);
        request.setUrl(url);
        //设置原始内容，长度限制为512字节，该字段会在响应中原样返回
        request.setDataId("DataId");
        //回调地址，以http://或者https://开头的地址。
        request.setCallback("https://github.com");
        //审核的场景类型，有效值：Porn（涉黄）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Ads。
        request.setDetectType("Porn,Ads");

        ciService.postDocumentAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交文档审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                PostAuditResult result = (PostAuditResult) cosResult;
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
     * 查询文档审核任务结果
     */
    private void getDocumentAudit() {
        //.cssg-snippet-body-start:[get-Document-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 审核任务的 ID
        String jobId = "iab1ca9fc8a3ed11ea834c525400863904";
        GetDocumentAuditRequest request = new GetDocumentAuditRequest(bucket, jobId);
        ciService.getDocumentAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询文档审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                GetDocumentAuditResult result = (GetDocumentAuditResult) cosResult;
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
     * 提交网页审核任务
     */
    private void postWebPageAudit() {
        //.cssg-snippet-body-start:[post-webpage-audit]

        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        //网页的链接地址
        String url = "https://github.com";
        PostWebPageAuditRequest request = new PostWebPageAuditRequest(bucket);
        request.setUrl(url);
        //回调地址，以http://或者https://开头的地址。
        request.setCallback("https://github.com");
        //审核的场景类型，有效值：Porn（涉黄）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Ads。
        request.setDetectType("Porn,Ads");
        //指定是否需要高亮展示网页内的违规文本，查询及回调结果时会根据此参数决定是否返回高亮展示的 html 内容。取值为 true 或者 false，默认为 false。
        request.setReturnHighlightHtml(true);

        ciService.postWebPageAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 提交网页审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                PostAuditResult result = (PostAuditResult) cosResult;
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
     * 查询网页审核任务结果
     */
    private void getWebPageAudit() {
        //.cssg-snippet-body-start:[get-webpage-audit]
        // 存储桶名称，格式为 BucketName-APPID
        String bucket = "examplebucket-1250000000";
        // 审核任务的 ID
        String jobId = "iab1ca9fc8a3ed11ea834c525400863904";
        GetWebPageAuditRequest request = new GetWebPageAuditRequest(bucket, jobId);
        ciService.getWebPageAuditAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult cosResult) {
                // result 查询网页审核任务的结果
                // 详细字段请查看api文档或者SDK源码
                GetWebPageAuditResult result = (GetWebPageAuditResult) cosResult;
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

        // 图片批量审核
        postImagesAudit();

        // 查询图片审核任务结果
        getImageAudit();

        // 提交视频审核任务
        postVideoAudit();

        // 查询视频审核任务结果
        getVideoAudit();

        // 提交音频审核任务
        postAudioAudit();

        // 查询音频审核任务结果
        getAudioAudit();

        // 提交文本审核任务
        postTextAudit();

        // 查询文本审核任务结果
        getTextAudit();

        // 提交文档审核任务
        postDocumentAudit();

        // 查询文档审核任务结果
        getDocumentAudit();

        // 提交网页审核任务
        postWebPageAudit();

        // 查询网页审核任务结果
        getWebPageAudit();
        // .cssg-methods-pragma
    }
}
