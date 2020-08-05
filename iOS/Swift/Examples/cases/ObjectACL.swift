import XCTest
import QCloudCOSXML

class ObjectACL: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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
    
    
    // 设置对象 ACL
    func putObjectAcl() {
        //.cssg-snippet-body-start:[swift-put-object-acl]
        let putObjectACl = QCloudPutObjectACLRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putObjectACl.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        putObjectACl.object = "exampleobject";
        let grantString = "id=\"100000000001\"";
        
        // grantFullControl 等价于 grantRead + grantWrite
        putObjectACl.grantFullControl = grantString;
        // 赋予被授权者读权限。
        putObjectACl.grantRead = grantString;
        // 赋予被授权者写权限。
        putObjectACl.grantWrite = grantString;
        
        putObjectACl.finishBlock = {(result,error)in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putObjectACL(putObjectACl);
        
        //.cssg-snippet-body-end
    }
    
    
    // 获取对象 ACL
    func getObjectAcl() {
        //.cssg-snippet-body-start:[swift-get-object-acl]
        let getObjectACL = QCloudGetObjectACLRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        getObjectACL.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        getObjectACL.object = "exampleobject";
        getObjectACL.setFinish { (result, error) in
            if let result = result {
                // 对象授权信息
                let acl = result.accessControlList
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getObjectACL(getObjectACL);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testObjectACL() {
        // 设置对象 ACL
        self.putObjectAcl();
        // 获取对象 ACL
        self.getObjectAcl();
        // .cssg-methods-pragma
    }
}
