import XCTest
import QCloudCOSXML

class BucketDomain: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 设置存储桶源站
    func putBucketDomain() {
      
        //.cssg-snippet-body-start:[swift-put-bucket-domain]
        
        let req = QCloudPutBucketDomainRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        
        let config = QCloudDomainConfiguration.init();
        let rule = QCloudDomainRule.init();
        // 开启状态，可选 .enabled, .disabled
        rule.status = .enabled;
        rule.name = "www.baidu.com";
        
        // 替换已存在的配置、有效值CNAME/TXT 填写则强制校验域名所有权之后，再下发配置
        rule.replace = .txt;
        rule.type = .rest;
        
        // 规则描述集合的数组
        config.rules = [rule];
        
        // 域名配置的规则
        req.domain = config;
        req.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketDomain(req);
        
        //.cssg-snippet-body-end

    }

    // 获取存储桶源站
    func getBucketDomain() {
        
        //.cssg-snippet-body-start:[swift-get-bucket-domain]
        let req = QCloudGetBucketDomainRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        
        req.finishBlock = {(result,error) in
            if let result = result {
                // result 包含源站信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketDomain(req);
        
        //.cssg-snippet-body-end
          
    }
    // .cssg-methods-pragma

    func testBucketDomain() {
        // 设置存储桶源站
        self.putBucketDomain();
        // 获取存储桶源站
        self.getBucketDomain();
        // .cssg-methods-pragma
    }
}
