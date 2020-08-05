import XCTest
import QCloudCOSXML

class BucketLifecycle: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 设置存储桶生命周期
    func putBucketLifecycle() {
        //.cssg-snippet-body-start:[swift-put-bucket-lifecycle]
        let putBucketLifecycleReq = QCloudPutBucketLifecycleRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putBucketLifecycleReq.bucket = "examplebucket-1250000000";
        
        let config = QCloudLifecycleConfiguration.init();
        
        // 规则描述
        let rule = QCloudLifecycleRule.init();
        
        // 用于唯一地标识规则
        rule.identifier = "swift";
        
        // 指明规则是否启用，枚举值：Enabled，Disabled
        rule.status = .enabled;
        
        // Filter 用于描述规则影响的 Object 集合
        let fileter = QCloudLifecycleRuleFilter.init();
        
        // 指定规则所适用的前缀。匹配前缀的对象受该规则影响，Prefix 最多只能有一个
        fileter.prefix = "0";
        
        // Filter 用于描述规则影响的 Object 集合
        rule.filter = fileter;
        
        // 规则转换属性，对象何时转换为 Standard_IA 或 Archive
        let transition = QCloudLifecycleTransition.init();
        
        // 指明规则对应的动作在对象最后的修改日期过后多少天操作：
        transition.days = 100;
        
        // 指定 Object 转储到的目标存储类型，枚举值： STANDARD_IA，ARCHIVE
        transition.storageClass = .standardIA;
        
        rule.transition = transition;
        
        putBucketLifecycleReq.lifeCycle = config;
        
        // 生命周期配置
        putBucketLifecycleReq.lifeCycle.rules = [rule];
        
        putBucketLifecycleReq.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketLifecycle(putBucketLifecycleReq);
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶生命周期
    func getBucketLifecycle() {
        //.cssg-snippet-body-start:[swift-get-bucket-lifecycle]
        let getBucketLifeCycle = QCloudGetBucketLifecycleRequest.init();
        getBucketLifeCycle.bucket = "examplebucket-1250000000";
        getBucketLifeCycle.setFinish { (config, error) in
            if let config = config {
                // 生命周期规则
                let rules = config.rules
            } else {
                print(error!);
            }
         
        };
        QCloudCOSXMLService.defaultCOSXML().getBucketLifecycle(getBucketLifeCycle);
        
        //.cssg-snippet-body-end
    }

    // 删除存储桶生命周期
    func deleteBucketLifecycle() {
        //.cssg-snippet-body-start:[swift-delete-bucket-lifecycle]
        let deleteBucketLifeCycle = QCloudDeleteBucketLifeCycleRequest.init();
        deleteBucketLifeCycle.bucket = "examplebucket-1250000000";
        deleteBucketLifeCycle.finishBlock = { (result, error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        };
        QCloudCOSXMLService.defaultCOSXML().deleteBucketLifeCycle(deleteBucketLifeCycle);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    func testBucketLifecycle() {
        // 设置存储桶生命周期
        self.putBucketLifecycle();
        // 获取存储桶生命周期
        self.getBucketLifecycle();
        // 删除存储桶生命周期
        self.deleteBucketLifecycle();
        // .cssg-methods-pragma
    }
}
