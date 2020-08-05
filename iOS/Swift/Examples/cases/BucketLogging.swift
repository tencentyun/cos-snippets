import XCTest
import QCloudCOSXML

class BucketLogging: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    func fenceQueue(_ queue: QCloudCredentailFenceQueue!,
                    requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let cre = QCloudCredential.init();
        //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
        cre.secretID = "COS_SECRETID";
        cre.secretKey = "COS_SECRETKEY";
        cre.token = "COS_TOKEN";
        /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
        cre.startDate = DateFormatter().date(from: "startTime"); // 单位是秒
        cre.experationDate = DateFormatter().date(from: "expiredTime");
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

    // 开启存储桶日志服务
    func putBucketLogging() {
        //.cssg-snippet-body-start:[swift-put-bucket-logging]
        let req = QCloudPutBucketLoggingRequest.init();
        
        // 说明日志记录配置的状态，如果无子节点信息则意为关闭日志记录
        let status = QCloudBucketLoggingStatus.init();
        
        // 存储桶 logging 设置的具体信息，主要是目标存储桶
        let loggingEnabled = QCloudLoggingEnabled.init();
        
        // 存放日志的目标存储桶，可以是同一个存储桶（但不推荐），或同一账户下、同一地域的存储桶
        // 存储桶名称，格式为 BucketName-APPID
        loggingEnabled.targetBucket = "examplebucket-1250000000";
        
        // 日志存放在目标存储桶的指定路径
        loggingEnabled.targetPrefix = "logs/";
        
        status.loggingEnabled = loggingEnabled;
        req.bucketLoggingStatus = status;
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        req.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().putBucketLogging(req);
        //.cssg-snippet-body-end
    }

    // 获取存储桶日志服务
    func getBucketLogging() {
        //.cssg-snippet-body-start:[swift-get-bucket-logging]
        let req = QCloudGetBucketLoggingRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        req.setFinish { (result, error) in
            if let result = result {
                // 日志配置信息
                let enabled = result.loggingEnabled
            } else {
                print(error!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().getBucketLogging(req);
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma


    func testBucketLogging() {
        // 开启存储桶日志服务
        self.putBucketLogging();
        // 获取存储桶日志服务
        self.getBucketLogging();
        // .cssg-methods-pragma
    }
}
