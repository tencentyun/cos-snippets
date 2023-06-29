import XCTest
import QCloudCOSXML

class PostConcat: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
    var credentialFenceQueue:QCloudCredentailFenceQueue?;
    var uploadId : String?;
    

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
    
    func fenceQueue(_ queue: QCloudCredentailFenceQueue!,
                    requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
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
    
    func signature(with fileds: QCloudSignatureFields!,
                   request: QCloudBizHTTPRequest!,
                   urlRequest urlRequst: NSMutableURLRequest!,
                   compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        self.credentialFenceQueue?.performAction({ (creator, error) in
            if error != nil {
                continueBlock(nil,error!);
            }else{
                let signature = creator?.signature(forData: urlRequst);
                continueBlock(signature,nil);
            }
        })
    }

    /**
     * 音视频拼接
     */
    func PostConcat() {
        let request = QCloudPostConcatRequest()
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000"
        // 存储桶所在地域
        request.regionName = "regionName"
        let input = QCloudInputPostConcat()
        input.input = QCloudInputPostConcatInput()
        input.input.object = "test.m3u8"
        input.operation = QCloudInputPostConcatOperation()
        input.operation.templateId = "TemplateId"
        input.operation.output = QCloudInputPostConcatOutput()
        input.operation.output.region = "ap-guangzhou"
        input.operation.output.bucket = "sample-125000000"
        input.operation.output.object = "test"
        request.input = input
        request.finishBlock = { result, error in
            // result 音视频拼接 ，详细字段请查看 API 文档或者 SDK 源码
        }
        QCloudCOSXMLService.defaultCOSXML().postConcat(request)

    }
}
