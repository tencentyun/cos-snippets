import XCTest
import QCloudCOSXML

class TransferCopyObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
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

    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        self.credentialFenceQueue?.performAction({ (creator, error) in
            if error != nil {
                continueBlock(nil,error!);
            }else{
                let signature = creator?.signature(forData: urlRequst);
                continueBlock(signature,nil);
            }
        })
    }


    // 高级接口拷贝对象
    func transferCopyObject() {
        //.cssg-snippet-body-start:[swift-transfer-copy-object]
        let copyRequest =  QCloudCOSXMLCopyObjectRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        copyRequest.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        copyRequest.object = "exampleobject";
        
        // 文件来源存储桶，需要是公有读或者在当前账号有权限
        // 存储桶名称，格式为 BucketName-APPID
        copyRequest.sourceBucket = "sourcebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        copyRequest.sourceObject = "sourceObject";
        
        // 源文件的 APPID
        copyRequest.sourceAPPID = "1250000000";
        
        // 来源的地域
        copyRequest.sourceRegion = "COS_REGION";
        
        copyRequest.setFinish { (copyResult, error) in
            if let copyResult = copyResult {
                // 文件的 etag
                let eTag = copyResult.eTag
            } else {
                print(error!);
            }
            
        }
        // 注意如果是跨地域复制，这里使用的 transferManager 所在的 region 必须为目标桶所在的 region
        QCloudCOSTransferMangerService.defaultCOSTransferManager().copyObject(copyRequest);
        
        // 取消copy
        // 若需要取消copy 调用cancel方法
        copyRequest.cancel();
        
        //.cssg-snippet-body-end
    }

    // .cssg-methods-pragma

    func testTransferCopyObject() {
        // 高级接口拷贝对象
        self.transferCopyObject();
        // .cssg-methods-pragma
    }
}
