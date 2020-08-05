import XCTest
import QCloudCOSXML

class BucketWebsite: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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
        // 在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
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
    
    
    /**
     * 设置存储桶静态网站
     */
    func putBucketWebsite() {
        //.cssg-snippet-body-start:[swift-put-bucket-website]
        let req = QCloudPutBucketWebsiteRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        
        let indexDocumentSuffix = "index.html";
        let errorDocKey = "error.html";
        let errorCode = 451;
        let replaceKeyPrefixWith = "404.html";
        
        let config = QCloudWebsiteConfiguration.init();
        
        let indexDocument = QCloudWebsiteIndexDocument.init();
        
        // 指定索引文档的对象键后缀。例如指定为index.html，那么当访问到存储桶的根目录时，会自动返回
        // index.html 的内容，或者当访问到article/目录时，会自动返回 article/index.html的内容
        indexDocument.suffix = indexDocumentSuffix;
        
        // 索引文档配置
        config.indexDocument = indexDocument;
        
        // 错误文档配置
        let errDocument = QCloudWebisteErrorDocument.init();
        errDocument.key = errorDocKey;
        
        // 指定通用错误文档的对象键，当发生错误且未命中重定向规则中的错误码重定向时，将返回该对象键的内容
        config.errorDocument = errDocument;
        
        // 重定向所有请求配置
        let redir = QCloudWebsiteRedirectAllRequestsTo.init();
        
        // 指定重定向所有请求的目标协议，只能设置为 https
        redir.protocol  = "https";
        config.redirectAllRequestsTo = redir;
        
        // 单条重定向规则配置
        let rule = QCloudWebsiteRoutingRule.init();
        
        // 重定向规则的条件配置
        let contition = QCloudWebsiteCondition.init();
        contition.httpErrorCodeReturnedEquals = Int32(errorCode);
        rule.condition = contition;
        
        // 重定向规则的具体重定向目标配置
        let webRe = QCloudWebsiteRedirect.init();
        webRe.protocol = "https";
        
        // 指定重定向规则的具体重定向目标的对象键，替换方式为替换原始请求中所匹配到的前缀部分，
        // 仅可在 Condition 为 KeyPrefixEquals 时设置
        webRe.replaceKeyPrefixWith = replaceKeyPrefixWith;
        rule.redirect = webRe;
        
        let routingRules = QCloudWebsiteRoutingRules.init();
        routingRules.routingRule = [rule];
        
        // 重定向规则配置，最多设置100条 RoutingRule
        config.rules = routingRules;
        req.websiteConfiguration  = config;
        
        req.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketWebsite(req);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * 获取存储桶静态网站
     */
    func getBucketWebsite() {
        //.cssg-snippet-body-start:[swift-get-bucket-website]
        let req = QCloudGetBucketWebsiteRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        
        req.setFinish {(result,error) in
            if let result = result {
                let rules = result.rules
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketWebsite(req);
        
        //.cssg-snippet-body-end
    }
    
    
    // 删除存储桶静态网站
    func deleteBucketWebsite() {
        //.cssg-snippet-body-start:[swift-delete-bucket-website]
        let delReq = QCloudDeleteBucketWebsiteRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        delReq.bucket = "examplebucket-1250000000";
        
        delReq.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().deleteBucketWebsite(delReq);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testBucketWebsite() {
        // 设置存储桶静态网站
        self.putBucketWebsite();
        // 获取存储桶静态网站
        self.getBucketWebsite();
        // 删除存储桶静态网站
        self.deleteBucketWebsite();
        // .cssg-methods-pragma
    }
}
