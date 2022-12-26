package com.tencent.qcloud.cosxml.cssg;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import com.tencent.cos.xml.CIService;
import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.ci.DescribeDocProcessBucketsRequest;
import com.tencent.cos.xml.model.ci.DescribeDocProcessBucketsResult;
import com.tencent.cos.xml.model.ci.PreviewDocumentInHtmlLinkRequest;
import com.tencent.cos.xml.model.ci.PreviewDocumentInHtmlLinkResult;
import com.tencent.cos.xml.model.ci.PreviewDocumentInHtmlRequest;
import com.tencent.cos.xml.model.ci.PreviewDocumentInHtmlResult;
import com.tencent.cos.xml.model.ci.PreviewDocumentRequest;
import com.tencent.cos.xml.model.ci.PreviewDocumentResult;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import org.junit.Test;

public class DocumentPreview {

    private Context context;
    private CosXmlService cosXmlService;
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
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey, sessionToken, startTime, expiredTime);
        }
    }

    /**
     * 查询文档预览开通状态
     */
    private void describeDocProcessBuckets() {
        //.cssg-snippet-body-start:[describe-docprocess-buckets]
        DescribeDocProcessBucketsRequest request = new DescribeDocProcessBucketsRequest();
        request.setPageNumber(1);
        request.setPageSize(20);
        ciService.describeDocProcessBucketsAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                // 详细字段请查看api文档或者SDK源码
                DescribeDocProcessBucketsResult describeDocProcessBucketsResult = (DescribeDocProcessBucketsResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
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
     * 文档预览
     */
    private void documentPreview() {
        //.cssg-snippet-body-start:[document-preview]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
		String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject.pdf"; //文档位于存储桶中的位置标识符，即对象键
        String localPath = "localdownloadpath"; // 保存在本地文件夹的路径
        int page = 1; // 需转换的文档页码，从 1 开始
        PreviewDocumentRequest previewDocumentRequest = new PreviewDocumentRequest(bucket,
                cosPath, localPath, page);

        cosXmlService.previewDocumentAsync(previewDocumentRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                // 详细字段请查看api文档或者SDK源码
                PreviewDocumentResult previewDocumentResult = (PreviewDocumentResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
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
     * 以HTML格式预览文档
     */
    private void previewDocumentInHtml() {
        //.cssg-snippet-body-start:[preview-document-in-html]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject.pdf"; //文档位于存储桶中的位置标识符，即对象键
        String localPath = "localdownloadpath"; // 保存在本地文件夹的路径
        PreviewDocumentInHtmlRequest request = new PreviewDocumentInHtmlRequest(bucket,
                cosPath, localPath);

        cosXmlService.previewDocumentInHtmlAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                PreviewDocumentInHtmlResult previewDocumentInHtmlResult = (PreviewDocumentInHtmlResult) result;
                String previewFilePath = previewDocumentInHtmlResult.getPreviewFilePath();
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
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
     * 以HTML格式链接预览文档
     */
    private void previewDocumentInHtmlLinkAsync() {
        //.cssg-snippet-body-start:[preview-document-in-html-link]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject.pdf"; //文档位于存储桶中的位置标识符，即对象键
        PreviewDocumentInHtmlLinkRequest request = new PreviewDocumentInHtmlLinkRequest(bucket,
                cosPath);

        cosXmlService.previewDocumentInHtmlLinkAsync(request, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                PreviewDocumentInHtmlLinkResult previewDocumentInHtmlLinkResult = (PreviewDocumentInHtmlLinkResult) result;
                String previewUrl = previewDocumentInHtmlLinkResult.getPreviewUrl();
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
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
     * 以HTML格式直出内容预览文档到字节数组
     * 注意：请不要通过本接口预览大文件，否则容易造成内存溢出
     */
    private void previewDocumentInHtmlBytes() {
        //.cssg-snippet-body-start:[preview-document-in-html-bytes]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        String cosPath = "exampleobject.pdf"; //文档位于存储桶中的位置标识符，即对象键
        try {
            byte[] bytes = cosXmlService.previewDocumentInHtmlBytes(bucket, cosPath);
        } catch (CosXmlClientException e) {
            e.printStackTrace();
        } catch (CosXmlServiceException e) {
            e.printStackTrace();
        }
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
        cosXmlService = new CosXmlService(context, serviceConfig, new ServerCredentialProvider());
        ciService = new CIService(context, serviceConfig, new ServerCredentialProvider());
    }

    @Test
    public void testDocumentPreview() {
        initService();

        //查询文档预览开通状态
        describeDocProcessBuckets();

        // 文档预览
        documentPreview();

        //以HTML格式预览文档
        previewDocumentInHtml();

        //以HTML格式链接预览文档
        previewDocumentInHtmlLinkAsync();

        //以HTML格式直出内容预览文档到字节数组
        previewDocumentInHtmlBytes();
        
        // .cssg-methods-pragma
    }
}
