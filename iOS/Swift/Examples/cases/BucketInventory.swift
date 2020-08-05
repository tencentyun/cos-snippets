import XCTest
import QCloudCOSXML

class BucketInventory: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 设置存储桶清单任务
    func putBucketInventory() {
        //.cssg-snippet-body-start:[swift-put-bucket-inventory]
        let putReq = QCloudPutBucketInventoryRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putReq.bucket = "examplebucket-1250000000";
        
        // 清单任务的名称
        putReq.inventoryID = "list1";
        
        // 用户在请求体中使用 XML 语言设置清单任务的具体配置信息。配置信息包括清单任务分析的对象，
        // 分析的频次，分析的维度，分析结果的格式及存储的位置等信息。
        let config = QCloudInventoryConfiguration.init();
        
        // 清单的名称，与请求参数中的 id 对应
        config.identifier = "list1";
        
        // 清单是否启用的标识：
        // 如果设置为 true，清单功能将生效
        // 如果设置为 false，将不生成任何清单
        config.isEnabled = "True";
        
        // 描述存放清单结果的信息
        let des = QCloudInventoryDestination.init();
        let btDes = QCloudInventoryBucketDestination.init();
        
        // 清单分析结果的文件形式，可选项为 CSV 格式
        btDes.cs = "CSV";
        
        // 存储桶的所有者 ID
        btDes.account = "1278687956";
        
        // 清单分析结果的存储桶名
        btDes.bucket  = "qcs::cos:ap-guangzhou::examplebucket-1250000000";
        
        // 清单分析结果的前缀
        btDes.prefix = "list1";
        
        // COS 托管密钥的加密方式
        let enc = QCloudInventoryEncryption.init();
        enc.ssecos = "";
        
        // 为清单结果提供服务端加密的选项
        btDes.encryption = enc;

        // 清单结果导出后存放的存储桶信息
        des.bucketDestination = btDes;
        
        // 描述存放清单结果的信息
        config.destination = des;
        
        // 配置清单任务周期
        let sc = QCloudInventorySchedule.init();
        
        // 清单任务周期，可选项为按日或者按周，枚举值：Daily、Weekly
        sc.frequency = "Daily";
        config.schedule = sc;
        let fileter = QCloudInventoryFilter.init();
        fileter.prefix = "myPrefix";
        config.filter = fileter;
        config.includedObjectVersions = .all;
        let fields = QCloudInventoryOptionalFields.init();
        fields.field = [ "Size",
                         "LastModifiedDate",
                         "ETag",
                         "StorageClass",
                         "IsMultipartUploaded",
                         "ReplicationStatus"];
        // 设置清单结果中应包含的分析项目
        config.optionalFields = fields;
        putReq.inventoryConfiguration = config;
        
        putReq.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().putBucketInventory(putReq);
        //.cssg-snippet-body-end

    }


    // 获取存储桶清单任务
    func getBucketInventory() {
        //.cssg-snippet-body-start:[swift-get-bucket-inventory]
        let req = QCloudGetBucketInventoryRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        // 清单任务的名称
        req.inventoryID = "list1";
        req.setFinish {(result,error) in
            if let result = result {
                // 任务信息
                let enabled = result.isEnabled
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketInventory(req);
        //.cssg-snippet-body-end
    }


    // 删除存储桶清单任务
    func deleteBucketInventory() {
        //.cssg-snippet-body-start:[swift-delete-bucket-inventory]
        let delReq = QCloudDeleteBucketInventoryRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        delReq.bucket = "examplebucket-1250000000";
        
        // 清单任务的名称
        delReq.inventoryID = "list1";
        delReq.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().deleteBucketInventory(delReq);
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma


    func testBucketInventory() {
        // 设置存储桶清单任务
        self.putBucketInventory();
        // 获取存储桶清单任务
        self.getBucketInventory();
        // 删除存储桶清单任务
        self.deleteBucketInventory();
        // .cssg-methods-pragma
    }
}
