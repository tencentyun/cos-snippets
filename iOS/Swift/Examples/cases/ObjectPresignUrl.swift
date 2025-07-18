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
                downloadFile(presignedURL: url, retryCount: 0)
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getPresignedURL(getPresignedURLRequest);
        
        
        //.cssg-snippet-body-end
    }

   func downloadFile(presignedURL: String, retryCount: Int) {
    // 使用预签名链接进行下载文件
    guard let url = URL(string: presignedURL) else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    // 指定HTTPMethod为GET
    request.httpMethod = "GET"

    let task = URLSession.shared.downloadTask(with: request) { location, response, error in
        if let error = error {
            if (self.isNetworkErrorAndRecoverable(error as NSError) || (error as NSError).code >= 500) && retryCount == 0 {
                self.downloadFile(presignedURL: presignedURL, retryCount: retryCount + 1)
            }
        } else if let location = location {
            // location 下载成功后的本地文件路径
            print("Downloaded file location: \(location)")
        }

        // 在 response 中查看下载结果
        if let httpResponse = response as? HTTPURLResponse {
            print("Download completed with status code: \(httpResponse.statusCode)")
        }
    }

    task.resume()
}
    
    // 获取预签名上传链接
    func getPresignUploadUrl() {
        //.cssg-snippet-body-start:[swift-get-presign-upload-url]
        let getPresign  = QCloudGetPresignedURLRequest.init();
        
        
        // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
        getPresign.bucket = "examplebucket-1250000000" ;
        
        
        // 使用预签名 URL 请求的 HTTP 方法。有效值（大小写敏感）为：
        // @"GET"、@"PUT"、@"POST"、@"DELETE"
        getPresign.httpMethod = "GET";
        
        
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
                 uploadFile(presignedURL: url, retryCount: 0)
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().getPresignedURL(getPresign);

        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    func uploadFile(presignedURL: String, retryCount: Int) {
           // 使用预签名链接进行上传文件
           guard let url = URL(string: presignedURL) else {
               print("Invalid URL")
               return
           }

           var request = URLRequest(url: url)
           // 指定HTTPMethod 为PUT
           request.httpMethod = "PUT"

           // fromData 为需要上传的文件
           let dataToUpload = "testtest".data(using: .utf8)!

           let task = URLSession.shared.uploadTask(with: request, from: dataToUpload) { data, response, error in
               if let error = error {
                   if (self.isNetworkErrorAndRecoverable(error as NSError) || (error as NSError).code >= 500) && retryCount == 0 {
                       self.uploadFile(presignedURL: presignedURL, retryCount: retryCount + 1)
                   }
               }

               // 在 response 中查看上传结果
               // 具体错误码请查看 https://cloud.tencent.com/document/product/436/7730#.E9.94.99.E8.AF.AF.E7.A0.81.E5.88.97.E8.A1.A8
               if let httpResponse = response as? HTTPURLResponse {
                   print("Upload completed with status code: \(httpResponse.statusCode)")
               }
           }

           task.resume()
       }
    
    func isNetworkErrorAndRecoverable(_ error: NSError) -> Bool {
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorCancelled,
                 NSURLErrorBadURL,
                 NSURLErrorNotConnectedToInternet,
                 NSURLErrorSecureConnectionFailed,
                 NSURLErrorServerCertificateHasBadDate,
                 NSURLErrorServerCertificateUntrusted,
                 NSURLErrorServerCertificateHasUnknownRoot,
                 NSURLErrorServerCertificateNotYetValid,
                 NSURLErrorClientCertificateRejected,
                 NSURLErrorClientCertificateRequired,
                 NSURLErrorCannotLoadFromNetwork:
                return false
            case NSURLErrorCannotConnectToHost:
                fallthrough
            default:
                return true
            }
        }
    
        if let userInfo = error.userInfo as? [String: Any],
           let serverCode = userInfo["Code"] as? String {
            if serverCode == "InvalidDigest" || serverCode == "BadDigest" ||
               serverCode == "InvalidSHA1Digest" || serverCode == "RequestTimeOut" {
                return true
            }
        }
    
        return false
    }
    
    func testObjectPresignUrl() {
        // 获取预签名下载链接
        self.getPresignDownloadUrl();
        // 获取预签名上传链接
        self.getPresignUploadUrl();
        // .cssg-methods-pragma
    }
}
