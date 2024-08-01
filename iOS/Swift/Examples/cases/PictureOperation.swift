import XCTest
import QCloudCOSXML
class PictureOperation: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

    var credentialFenceQueue:QCloudCredentailFenceQueue?;

    override func setUp() {
        let config = QCloudServiceConfiguration.init();
        config.signatureProvider = self;
        config.appID = "1253653367";
        let endpoint = QCloudCOSXMLEndPoint.init();
        endpoint.regionName = "ap-guangzhou";//服务地域名称，可用的地域请参考注释
        endpoint.useHTTPS = true;
        config.endpoint = endpoint;
        QCloudCOSXMLService.registerDefaultCOSXML(with: config);
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: config);

        // 脚手架用于获取临时密钥
        self.credentialFenceQueue = QCloudCredentailFenceQueue();
        self.credentialFenceQueue?.delegate = self;
    }

    func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let cre = QCloudCredential.init();
        //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
        cre.secretID = "COS_SECRETID";
        cre.secretKey = "COS_SECRETKEY";
        cre.token = "COS_TOKEN";
        /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
        cre.startDate = DateFormatter().date(from: "startTime"); // 单位是秒
        cre.expirationDate = DateFormatter().date(from: "expiredTime");
        let auth = QCloudAuthentationV5Creator.init(credential: cre);
        continueBlock(auth,nil);
    }

    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        self.credentialFenceQueue?.performAction({ (creator, error) in
            if error != nil {
                continueBlock(nil,error!);
            }else{
                let signature = creator?.signature(forData: urlRequst);
                continueBlock(signature,nil);
            }
        })
    }


    // 上传时图片处理
    func uploadWithPicOperation() {
        //.cssg-snippet-body-start:[swift-upload-with-pic-operation]
        let request = QCloudCIUploadOperationsRequest<AnyObject>()
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
        request.object = "exampleobject"
        // 存储桶名称，由 BucketName-Appid 组成，可以在 COS 控制台查看 https://console.cloud.tencent.com/cos5/bucket
        request.bucket = "examplebucket-1250000000"
        request.body = NSData();
        let op = QCloudPicOperations()
        // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
        op.is_pic_info = false
        let rule = QCloudPicOperationRule()
        op.rule = [rule]
        request.picOperations = op
        request.setFinish { result, error in
            
        }
        QCloudCOSXMLService.defaultCOSXML().uploadOperations(request)
        //.cssg-snippet-body-end
    }


    // 对云上数据进行图片处理
    func processWithPicOperation() {
        //.cssg-snippet-body-start:[swift-process-with-pic-operation]
        let put = QCloudCICloudDataOperationsRequest<AnyObject>();
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        // 存储桶名称，格式为 BucketName-APPID
        
        put.bucket = "examplebucket-1250000000";
        let op = QCloudPicOperations.init();
        
        // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
        op.is_pic_info = false;
        
        let rule = QCloudPicOperationRule.init();
        
        // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
        
        rule.fileid = "test";
        
        // 盲水印文字，需要经过 URL 安全的 Base64 编码。当 type 为3时必填，type 为1或2时无效。
        rule.text = "123";
        
        // 盲水印类型，有效值：1 半盲；2 全盲；3 文字
        rule.type = .text;
        
        op.rule = [rule];
        put.picOperations = op;
        put.setFinish { (outoutObject, error) in
            
        };
        QCloudCOSXMLService.defaultCOSXML().cloudDataOperations(put);
        //.cssg-snippet-body-end
    }

    // 上传时添加盲水印
    func putObjectWithWatermark() {
        //不支持
        //.cssg-snippet-body-start:[swift-put-object-with-watermark]
        let put = QCloudPutObjectWatermarkRequest<AnyObject>();
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        // 存储桶名称，格式为 BucketName-APPID
        
        put.bucket = "examplebucket-1250000000";
        put.body = "123456789".data(using: .utf8)! as NSData;
        let op = QCloudPicOperations.init();
        
        // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
        op.is_pic_info = false;
        
        let rule = QCloudPicOperationRule.init();
        
        // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
        
        rule.fileid = "test";
        //操作：有效值 :QCloudPicOperationRuleActionPut:添加盲水印  QCloudPicOperationRuleActionExtrac:提取盲水印
        rule.actionType = .put;
        
        // 盲水印类型，有效值：QCloudPicOperationRuleHalf 半盲；QCloudPicOperationRuleFull: 全盲；QCloudPicOperationRuleText 文字
        rule.type = .full;
        // 盲水印图片在cos上的地址：如http://ci-1253653367.cos.ap-guangzhou.myqcloud.com/watermark_icon.png
        rule.imageURL = "watermarkURL";
        op.rule = [rule];
        put.picOperations = op;
        put.setFinish { (outoutObject, error) in
            
        };
        QCloudCOSXMLService.defaultCOSXML().putWatermarkObject(put);
        //.cssg-snippet-body-end
    }


    // 下载时添加盲水印
    func downloadObjectWithWatermark() {
        //不支持
        //.cssg-snippet-body-start:[swift-download-object-with-watermark]
        let request : QCloudGetObjectRequest = QCloudGetObjectRequest();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";

        // 设置下载的路径 URL，如果设置了，文件将会被下载到指定路径中
        request.downloadingURL = NSURL.fileURL(withPath: "Local File Path") as URL!;

        // 本地已下载的文件大小，如果是从头开始下载，请不要设置
        request.localCacheDownloadOffset = 100;

        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/19017
        request.watermarkRule = "watermark/3/type/2/image/aHR0cDovL2NpLTEyNTM2NTMzNjcuY29zLmFwLWd1YW5nemhvdS5teXFjbG91ZC5jb20vcHJvdGVjdGlvbl9ibGluZF93YXRlcm1hcmtfaWNvbi5wbmc=";

        // 监听下载进度
        request.sendProcessBlock = { (bytesDownload, totalBytesDownload,
            totalBytesExpectedToDownload) in
            
            // bytesDownload                   新增字节数
            // totalBytesDownload              本次下载接收的总字节数
            // totalBytesExpectedToDownload    本次下载的目标字节数
        }

        // 监听下载结果
        request.finishBlock = { (result, error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }

        QCloudCOSXMLService.defaultCOSXML().getObject(request);
        //.cssg-snippet-body-end
    }


    // 图片审核
    func sensitiveContentRecognition() {
        //不支持
        //.cssg-snippet-body-start:[swift-sensitive-content-recognition]
        let request : QCloudSyncImageRecognitionRequest = QCloudSyncImageRecognitionRequest();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "bucket";

        // 文件所在地域
        request.regionName = "regionName";

        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "***.jpg";
            
        request.finishBlock = { (result, error) in
                // outputObject 提交审核反馈信息，详细字段请查看api文档或者SDK源码
            // QCloudImageRecognitionResult 类；
        }
        QCloudCOSXMLService.defaultCOSXML().syncImageRecognition(request);
        //.cssg-snippet-body-end
    }

    func batchimageRecognition(){
        //.cssg-snippet-body-start:[swift-batch-image-recognition]
        let request = QCloudBatchimageRecognitionRequest();
        request.bucket = "bucket";

        // 文件所在地域
        request.regionName = "regionName";

        // 待审核的图片对象
        let input1 = QCloudBatchRecognitionImageInfo();
        input1.object = "***.jpg";

        let input2 = QCloudBatchRecognitionImageInfo();
        input2.object = "***.jpg";

        // 待审核的图片对象数组
        request.input = [input1,input2];
        request.setFinish { outputObject, error in
        // outputObject 审核结果，详细字段请查看api文档或者SDK源码
        // QCloudBatchImageRecognitionResult 类；
        }
        QCloudCOSXMLService.defaultCOSXML().batchImageRecognition(request);
        //.cssg-snippet-body-end
    }
    
    func getImageRecognition(){
        let request = QCloudGetImageRecognitionRequest();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        request.regionName = "regionName";

        // 同步审核或批量审核返回结果的jobid
        request.jobId = "jobid";

        request.setFinish { outputObject, error in
            // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudWebRecognitionResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().getImageRecognition(request);
    }

    func PostImageAuditReport() {
        let request = QCloudPostImageAuditReportRequest()
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000"
        // 文件所在地域
        request.regionName = "regionName"


        let input = QCloudPostImageAuditReport()
        input.contentType = 2
        input.label = "Label"
        input.suggestedLabel = "Normal"
        request.input = input
        request.finishBlock = { result, error in
            /// result 文本审核结果反馈 ，详细字段请查看 API 文档或者 SDK 源码
        }
        QCloudCOSXMLService.defaultCOSXML().postImageAuditReport(request)
    }

    // 下载时进行图片处理
    func downloadWithPicOperation() {
        //.cssg-snippet-body-start:[swift-download-with-pic-operation]
        
        //.cssg-snippet-body-end
    }



    // .cssg-methods-pragma

    func testPictureOperation() {
        // 上传时图片处理
        self.uploadWithPicOperation();

        // 对云上数据进行图片处理
        self.processWithPicOperation();
        // 上传时添加盲水印
        self.putObjectWithWatermark();
        // 下载时添加盲水印
        self.downloadObjectWithWatermark();
        // 图片审核
        self.sensitiveContentRecognition();

        self.batchimageRecognition();
        // 下载时进行图片处理
        self.downloadWithPicOperation();
        
        self.getImageRecognition();
        // .cssg-methods-pragma
    }
}
