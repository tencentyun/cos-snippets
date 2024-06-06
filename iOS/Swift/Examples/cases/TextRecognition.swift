import XCTest
import QCloudCOSXML
class TextRecognition: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 提交审核任务
    func putTextRecognition() {
        //.cssg-snippet-body-start:[swift-put-text-recognition]
        
        let request = QCloudPostTextRecognitionRequest();    
        // content:纯文本信息
        // object:对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        // url:文本文件的完整链接
        // 单次请求只能使用 Object 、Content、Url 中的一个。
        // 当选择 Object、Url 时，审核结果为异步返回，可通过 查询文本审核任务结果 API 接口获取返回结果。
        // 当选择 Content 时，审核结果为同步返回，可通过 响应体 查看返回结果。
        request.content = "文本内容";
        
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";
    
        // 文件所在地域
        request.regionName = "regionName";
        
        // 审核策略，不带审核策略时使用默认策略。具体查看 https://cloud.tencent.com/document/product/460/56345
        request.setFinish { outputObject, error in
            // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudPostTextRecognitionResult 类；
        }
        QCloudCOSXMLService.defaultCOSXML().postTextRecognition(request);
        
        //.cssg-snippet-body-end
    }

    // 查询审核任务
    func getTextRecognitionResult() {
        //.cssg-snippet-body-start:[swift-get-text-recognition]
        let request = QCloudGetTextRecognitionRequest();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // 文件所在地域
        request.regionName = "regionName";

        // QCloudPostTextRecognitionRequest接口返回的jobid
        request.jobId = "jobid";

        request.setFinish { outputObject, error in
            // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudTextRecognitionResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().getTextRecognition(request);
        //.cssg-snippet-body-end
    }
    
    func PostTextAuditReport() {
        let request = QCloudPostTextAuditReportRequest()
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000"
        // 文件所在地域
        request.regionName = "regionName"
        let input = QCloudPostTextAuditReport()
        input.contentType = 1
        input.label = "Label"
        input.suggestedLabel = "Normal"
        request.input = input
        request.finishBlock = { result, error in
          /// result 文本审核结果反馈 ，详细字段请查看 API 文档或者 SDK 源码
        }
        QCloudCOSXMLService.defaultCOSXML().postTextAuditReport(request)

    }
    
    // .cssg-methods-pragma

    func testTextOperation() {
        // 提交审核任务
        self.putTextRecognition();

        // 查询审核任务
        self.getTextRecognitionResult();
    
        // .cssg-methods-pragma
    }
}
