import XCTest
import QCloudCOSXML

class HeadObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 获取对象信息
    func headObject() {
        //.cssg-snippet-body-start:[swift-head-object]
        let headObject = QCloudHeadObjectRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        headObject.bucket = "examplebucket-1250000000";
        
        // versionId 当启用版本控制时，指定要查询的版本 ID，如不指定则查询对象的最新版本
        headObject.versionID = "versionID";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        headObject.object  = "exampleobject";
        headObject.finishBlock =  {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
                // 获取文件crc64
                let crc64 = (result as? NSObject)?.__originHTTPURLResponse__.allHeaderFields["x-cos-hash-crc64ecma"];
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().headObject(headObject);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma


    func doesObjectExist() {

        //.cssg-snippet-body-start:[objc-object-exist]
        
        // 存储桶名称，格式为 BucketName-APPID
        let bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
        let object  = "exampleobject";

        QCloudCOSXMLService.defaultCOSXML().doesObjectExist(withBucket: bucket, object: object);
        
        //.cssg-snippet-body-end
        
    }
    
    func testHeadObject() {
        // 获取对象信息
        self.headObject();
        self.doesObjectExist();
        // .cssg-methods-pragma
    }
}
