import XCTest
import QCloudCOSXML

class BucketTagging: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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
    
    
    /**
     * 用于为存储桶设置键值对作为存储桶标签，可以协助您管理已有的存储桶资源，并通过标签进行成本管理。
     */
    func putBucketTagging() {
        //.cssg-snippet-body-start:[swift-put-bucket-tagging]
        let req = QCloudPutBucketTaggingRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        let taggings = QCloudBucketTagging.init();
        
        // 标签集合
        let tagSet = QCloudBucketTagSet.init();
        taggings.tagSet = tagSet;
        let tag1 = QCloudBucketTag.init();
        
        // 标签的 Key，长度不超过128字节, 支持英文字母、数字、空格、加号、减号、下划线、等号、点号、
        // 冒号、斜线
        tag1.key = "age";
        
        // 标签的 Value，长度不超过256字节, 支持英文字母、数字、空格、加号、减号、下划线、等号、点号
        // 、冒号、斜线
        tag1.value = "20";
        
        let tag2 = QCloudBucketTag.init();
        tag2.key = "name";
        tag2.value = "karis";
        
        // 标签集合，最多支持10个标签
        tagSet.tag = [tag1,tag2];
        
        // 标签集合
        req.taggings = taggings;
        req.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketTagging(req);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * 用于查询指定存储桶下已有的存储桶标签。
     */
    func getBucketTagging() {
        //.cssg-snippet-body-start:[swift-get-bucket-tagging]
        let req = QCloudGetBucketTaggingRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        req.setFinish { (result, error) in
            if let result = result {
                // 标签集合
                let tagSet = result.tagSet
            } else {
                print(error!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().getBucketTagging(req);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * 用于删除指定存储桶下已有的存储桶标签。
     */
    func deleteBucketTagging() {
        //.cssg-snippet-body-start:[swift-delete-bucket-tagging]
        let req = QCloudDeleteBucketTaggingRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        req.finishBlock =  { (result, error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().deleteBucketTagging(req);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    func testBucketTagging() {
        // 设置存储桶标签
        self.putBucketTagging();
        // 获取存储桶标签
        self.getBucketTagging();
        // 删除存储桶标签
        self.deleteBucketTagging();
        // .cssg-methods-pragma
    }
}
