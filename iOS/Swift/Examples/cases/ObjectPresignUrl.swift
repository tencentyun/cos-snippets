import XCTest
import QCloudCOSXML

class ObjectPresignUrl: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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
    
    
    // 获取预签名下载链接
    func getPresignDownloadUrl() {
        //.cssg-snippet-body-start:[swift-get-presign-download-url]
        let getPresignedURLRequest = QCloudGetPresignedURLRequest();
        
        
        // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
        getPresignedURLRequest.bucket = "examplebucket-1250000000";
        
        
        // 使用预签名 URL 请求的 HTTP 方法。有效值（大小写敏感）为：@"GET"、@"PUT"、@"POST"、@"DELETE"
        getPresignedURLRequest.httpMethod = "PUT";
        
        
        // 获取预签名函数，默认签入Header Host；您也可以选择不签入Header Host，但可能导致请求失败或安全漏洞
        getPresignedURLRequest.signHost = true;
        
        
        // http 请求参数，传入的请求参数需与实际请求相同，能够防止用户篡改此HTTP请求的参数
        getPresignedURLRequest.setValue("value1", forRequestParameter: "param1")
        getPresignedURLRequest.setValue("value2", forRequestParameter: "param2")
        
        
        // http 请求头部，传入的请求头部需包含在实际请求中，能够防止用户篡改签入此处的HTTP请求头部
        getPresignedURLRequest.setValue("value1", forRequestHeader: "param1")
        getPresignedURLRequest.setValue("value2", forRequestHeader: "param2")
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
        getPresignedURLRequest.object = "exampleobject";
        getPresignedURLRequest.setFinish { (result, error) in
            if let result = result {
                // 预签名 URL
                let url = result.presienedURL
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getPresignedURL(getPresignedURLRequest);
        
        
        //.cssg-snippet-body-end
    }
    
    // 获取预签名上传链接
    func getPresignUploadUrl() {
        //.cssg-snippet-body-start:[swift-get-presign-upload-url]
        let getPresign  = QCloudGetPresignedURLRequest.init();
        
        
        // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
        getPresign.bucket = "examplebucket-1250000000" ;
        
        
        // 使用预签名 URL 请求的 HTTP 方法。有效值（大小写敏感）为：
        // @"GET"、@"PUT"、@"POST"、@"DELETE"
        getPresign.httpMethod = "PUT";
        
        
        // 获取预签名函数，默认签入Header Host；您也可以选择不签入Header Host，但可能导致请求失败或安全漏洞
        getPresign.signHost = true;
        
        
        // http 请求参数，传入的请求参数需与实际请求相同，能够防止用户篡改此HTTP请求的参数
        getPresign.setValue("value1", forRequestParameter: "param1")
        getPresign.setValue("value2", forRequestParameter: "param2")
        
        
        // http 请求头部，传入的请求头部需包含在实际请求中，能够防止用户篡改签入此处的HTTP请求头部
        getPresign.setValue("value1", forRequestHeader: "param1")
        getPresign.setValue("value2", forRequestHeader: "param2")
        
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
        getPresign.object = "exampleobject";
        getPresign.setFinish { (result, error) in
            if let result = result {
                // 预签名 URL
                let url = result.presienedURL
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getPresignedURL(getPresign);

        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testObjectPresignUrl() {
        // 获取预签名下载链接
        self.getPresignDownloadUrl();
        // 获取预签名上传链接
        self.getPresignUploadUrl();
        // .cssg-methods-pragma
    }
}
