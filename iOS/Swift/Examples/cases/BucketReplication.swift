import XCTest
import QCloudCOSXML

class BucketReplication: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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
    * 用于向已启用版本控制的存储桶中配置跨地域复制规则。如果存储桶已经配置了跨地域复制规则，那么该请
    * 求会替换现有配置。
    */
    func putBucketReplication() {
        //.cssg-snippet-body-start:[swift-put-bucket-replication]
        let putBucketReplication = QCloudPutBucketReplicationRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putBucketReplication.bucket = "examplebucket-1250000000";
        
        // 说明所有跨地域配置信息
        let config = QCloudBucketReplicationConfiguation.init();
        config.role = "qcs::cam::uin/100000000001:uin/100000000001";
        
        // 发起者身份标示
        let rule = QCloudBucketReplicationRule.init();
         
        // 用来标注具体 Rule 的名称
        rule.identifier = "rule1";
        // 规则开启状态，可选 .enabled, .disabled
        rule.status = .enabled;
        
        // 目标存储桶信息
        let destination = QCloudBucketReplicationDestination.init();
        let destinationBucket = "destinationbucket-1250000000";
        let region = "ap-beijing";
        destination.bucket = "qcs::cos:\(region)::\(destinationBucket)";
        rule.destination = destination;
        
        // 前缀匹配策略，不可重叠，重叠返回错误。前缀匹配根目录为空
        rule.prefix = "dir/";
        
        config.rule = [rule];
        
        putBucketReplication.configuation = config;
        
        putBucketReplication.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketRelication(putBucketReplication);
        
        //.cssg-snippet-body-end
    }


    /**
    * 接口用于查询存储桶中用户跨地域复制配置信息。用户发起该请求时需获得请求签名，表明该请求已获得许可。
    */
    func getBucketReplication() {
        //.cssg-snippet-body-start:[swift-get-bucket-replication]
        let getBucketReplication = QCloudGetBucketReplicationRequest.init();
        getBucketReplication.bucket = "examplebucket-1250000000";
        getBucketReplication.setFinish { (config, error) in
            if let config = config {
                // 配置信息列表
                let rule = config.rule
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketReplication(getBucketReplication);
        
        //.cssg-snippet-body-end
    }


    /**
    * 用来删除存储桶中的跨地域复制配置。用户发起该请求时需获得请求签名，表明该请求已获得许可。
    */
    func deleteBucketReplication() {
        //.cssg-snippet-body-start:[swift-delete-bucket-replication]
        let deleteBucketReplication = QCloudDeleteBucketReplicationRequest.init();
        deleteBucketReplication.bucket = "examplebucket-1250000000";
        deleteBucketReplication.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().deleteBucketReplication(deleteBucketReplication);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma


    func testBucketReplication() {
        // 设置存储桶跨地域复制规则
        self.putBucketReplication();
        // 获取存储桶跨地域复制规则
        self.getBucketReplication();
        // 删除存储桶跨地域复制规则
        self.deleteBucketReplication();
        // .cssg-methods-pragma
    }
}
