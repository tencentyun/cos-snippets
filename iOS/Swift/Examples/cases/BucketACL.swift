import XCTest
import QCloudCOSXML

class BucketACL: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 设置存储桶 ACL
    func putBucketAcl() {
        //.cssg-snippet-body-start:[swift-put-bucket-acl]
        let putBucketACLReq = QCloudPutBucketACLRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putBucketACLReq.bucket = "examplebucket-1250000000";
        
        // 授予权限的账号 ID
        let appTD = "100000000001";
        let ownerIdentifier = "qcs::cam::uin/\(appTD):uin/\(appTD)";
        let grantString = "id=\"\(ownerIdentifier)\"";
        // 赋予被授权者写权限
        putBucketACLReq.grantWrite = grantString;
        
        // 赋予被授权者读权限
        putBucketACLReq.grantRead = grantString;
        
        // 赋予被授权者读写权限 grantFullControl == grantRead + grantWrite
        putBucketACLReq.grantFullControl = grantString;
        
        putBucketACLReq.finishBlock = {(result,error) in
            if let result = result {
                // 可以从 result 中获取服务器返回的 header 信息
            } else {
                print(error!)
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketACL(putBucketACLReq);
        //.cssg-snippet-body-end
    }

    // 获取存储桶 ACL
    func getBucketAcl() {
        //.cssg-snippet-body-start:[swift-get-bucket-acl]
        let getBucketACLReq = QCloudGetBucketACLRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        getBucketACLReq.bucket = "examplebucket-1250000000";
        
        getBucketACLReq.setFinish { (result, error) in
            if let result = result {
                // ACL 授权信息
                let acl = result.accessControlList;
            } else {
                print(error!)
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketACL(getBucketACLReq)
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma


    func testBucketACL() {
        // 设置存储桶 ACL
        self.putBucketAcl();
        // 获取存储桶 ACL
        self.getBucketAcl();
        // .cssg-methods-pragma
    }
}
