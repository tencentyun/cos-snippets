import XCTest
import QCloudCOSXML

class BucketCORS: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶跨域规则
    func putBucketCors() {
        
        //.cssg-snippet-body-start:[swift-put-bucket-cors]
        let putBucketCorsReq = QCloudPutBucketCORSRequest.init();
        
        let corsConfig = QCloudCORSConfiguration.init();
        
        let rule = QCloudCORSRule.init();
        
        // 配置规则的 ID
        rule.identifier = "rule1";
        
        // 跨域请求可以使用的 HTTP 请求头部，支持通配符 *
        rule.allowedHeader = ["origin","host","accept","content-type","authorization"];
        rule.exposeHeader = "Etag";
        
        // 跨域请求允许的 HTTP 操作，例如：GET，PUT，HEAD，POST，DELETE
        rule.allowedMethod = ["GET","PUT","POST", "DELETE", "HEAD"];
        
        // 跨域请求得到结果的有效期
        rule.maxAgeSeconds = 3600;
        
        // 允许的访问来源，支持通配符 *，格式为：协议://域名[:端口]
        rule.allowedOrigin = "*";
        
        corsConfig.rules = [rule];
        putBucketCorsReq.corsConfiguration = corsConfig;
        
        // 存储桶名称，格式为 BucketName-APPID
        putBucketCorsReq.bucket = "examplebucket-1250000000";
        putBucketCorsReq.finishBlock = {(result,error) in
            if let result = result {
                // 可以从 result 中获取服务器返回的 header 信息
            } else {
                print(error!)
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketCORS(putBucketCorsReq);
        
        //.cssg-snippet-body-end
    }
    
    // 获取存储桶跨域规则
    func getBucketCors() {
        
        //.cssg-snippet-body-start:[swift-get-bucket-cors]
        let  getBucketCorsRes = QCloudGetBucketCORSRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        getBucketCorsRes.bucket = "examplebucket-1250000000";
        getBucketCorsRes.setFinish { (corsConfig, error) in
            if let corsConfig = corsConfig {
                // 跨域规则列表
                let rules = corsConfig.rules
            } else {
                print(error!)
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketCORS(getBucketCorsRes);
        
        //.cssg-snippet-body-end
    }

    // 实现 Object 跨域访问配置的预请求
    func optionObject() {
        
        //.cssg-snippet-body-start:[swift-option-object]
        let optionsObject = QCloudOptionsObjectRequest.init();
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        optionsObject.object = "exampleobject";
        
        // 模拟跨域访问的请求来源域名，请求 method，请求头部
        optionsObject.origin = "http://www.qcloud.com";
        optionsObject.accessControlRequestMethod = "GET";
        optionsObject.accessControlRequestHeaders = "origin";
        
        // 存储桶名称，格式为 BucketName-APPID
        optionsObject.bucket = "examplebucket-1250000000";
        
        optionsObject.finishBlock = {(result,error) in
            if let result = result {
                // 可以从 result 中获取服务器返回的 header 信息
            }
        }
        QCloudCOSXMLService.defaultCOSXML().optionsObject(optionsObject);
        
        //.cssg-snippet-body-end
    }


    // 删除存储桶跨域规则
    func deleteBucketCors() {
        //.cssg-snippet-body-start:[swift-delete-bucket-cors]
        let deleteBucketCorsRequest = QCloudDeleteBucketCORSRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        deleteBucketCorsRequest.bucket = "examplebucket-1250000000";
        
        deleteBucketCorsRequest.finishBlock = {(result,error) in
            if let result = result {
                // 可以从 result 中获取服务器返回的 header 信息
            } else {
                print(error!)
            }
        }
        QCloudCOSXMLService.defaultCOSXML().deleteBucketCORS(deleteBucketCorsRequest);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma


    func testBucketCORS() {
        // 设置存储桶跨域规则
        self.putBucketCors();
        // 获取存储桶跨域规则
        self.getBucketCors();
        // 实现 Object 跨域访问配置的预请求
        self.optionObject();
        // 删除存储桶跨域规则
        self.deleteBucketCors();
        // .cssg-methods-pragma
    }
}
