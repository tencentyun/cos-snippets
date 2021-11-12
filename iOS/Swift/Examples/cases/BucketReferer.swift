import XCTest
import QCloudCOSXML

class BucketReferer: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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
    
    
    // 设置存储桶 Referer
    func putBucketReferer() {
        //.cssg-snippet-body-start:[swift-put-bucket-referer]
        
        let request = QCloudPutBucketRefererRequest.init();

        // 防盗链类型，枚举值：Black-List、White-List
        reqeust.refererType = QCloudBucketRefererTypeBlackList;

        // 是否开启防盗链，枚举值：Enabled、Disabled
        reqeust.status = QCloudBucketRefererStatusEnabled;

        // 是否允许空 Referer 访问，枚举值：Allow、Deny，默认值为 Deny
        reqeust.configuration = QCloudBucketRefererConfigurationDeny;

        // 生效域名列表， 支持多个域名且为前缀匹配， 支持带端口的域名和 IP， 支持通配符*，做二级域名或多级域名的通配
        reqeust.domainList = ["*.com","*.qq.com"];

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        request.finishBlock = {(result,error) in
            if (error){
                // 添加防盗链失败
            }else{
                // 添加防盗链失败
            }
        }
        QCloudCOSXMLService.defaultCOSXML().PutBucketReferer(request);
        
        //.cssg-snippet-body-end
    }
    
    
    // 查询存储桶 Referer
    func getBucketReferer() {
        //.cssg-snippet-body-start:[swift-put-bucket-referer]
        let request = QCloudGetBucketRefererRequest.init();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        request.finishBlock = {(result,error) in
            // outputObject 请求到的防盗链，详细字段请查看api文档或者SDK源码
            // QCloudBucketRefererInfo 类；
        }
        QCloudCOSXMLService.defaultCOSXML().GetBucketReferer(request);
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testPutBucket() {
        // 设置存储桶 Referer
        self.putBucketReferer();
        // 查询存储桶 Referer
        self.getBucketReferer();
        // .cssg-methods-pragma
    }
}
