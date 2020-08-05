import XCTest
import QCloudCOSXML

class TransferObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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
    
    
    // 高级接口上传对象
    func transferUploadFile() {
        //.cssg-snippet-body-start:[swift-transfer-upload-file]
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        
        // 存储桶名称，格式为 BucketName-APPID
        put.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        
        // 需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
        put.body = NSURL.fileURL(withPath: "Local File Path") as AnyObject;
        
        // 监听上传结果
        put.setFinish { (result, error) in
            // 获取上传结果
            if let result = result {
                // 文件的 etag
                let eTag = result.eTag
            } else {
                print(error!);
            }
        }

        // 监听上传进度
        put.sendProcessBlock = { (bytesSent, totalBytesSent,
            totalBytesExpectedToSend) in
            // bytesSent                   新增字节数
            // totalBytesSent              本次上传的总字节数
            // totalBytesExpectedToSend    本地上传的目标字节数
        };
        // 设置上传参数
        put.initMultipleUploadFinishBlock = {(multipleUploadInitResult, resumeData) in
            // 在初始化分块上传完成以后会回调该 block，在这里可以获取 resumeData,以及 uploadId
            if let multipleUploadInitResult = multipleUploadInitResult {
                let uploadId = multipleUploadInitResult.uploadId
            }
        }
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
        
        // 如果需要取消上传，调用 abort 方法
        put.abort { (result, error) in
            
        }
        //.cssg-snippet-body-end
    }
    
    
    // 高级接口上传二进制数据
    func transferUploadBytes() {
        
        //.cssg-snippet-body-start:[swift-transfer-upload-bytes]
        
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        
        // 存储桶名称，格式为 BucketName-APPID
        put.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        
        // 需要上传的对象内容
        let dataBody:NSData = "wrwrwrwrwrw".data(using: .utf8)! as NSData;
        put.body = dataBody;
        
        // 监听上传结果
        put.setFinish { (result, error) in
            // 获取上传结果
            if let result = result {
                // 文件的 etag
                let eTag = result.eTag
            } else {
                print(error!);
            }
        }

        // 监听上传进度
        put.sendProcessBlock = { (bytesSent, totalBytesSent,
            totalBytesExpectedToSend) in
            
            // bytesSent                   新增字节数
            // totalBytesSent              本次上传的总字节数
            // totalBytesExpectedToSend    本地上传的目标字节数
        };
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
        //.cssg-snippet-body-end
    }

    // 高级接口流式上传
    func transferUploadStream() {
        
        //.cssg-snippet-body-start:[swift-transfer-upload-stream]

        //.cssg-snippet-body-end

    }
    
    // 高级接口下载对象
    func transferDownloadObject() {
        //.cssg-snippet-body-start:[swift-transfer-download-object]
        let request : QCloudCOSXMLDownloadObjectRequest = QCloudCOSXMLDownloadObjectRequest();
        
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";
        
        // 设置下载的路径 URL，如果设置了，文件将会被下载到指定路径中
        request.downloadingURL = NSURL.fileURL(withPath: "Local File Path") as URL?;
        
        // 本地已下载的文件大小，如果是从头开始下载，请不要设置
        request.localCacheDownloadOffset = 100;

        // 监听下载进度
        request.sendProcessBlock = { (bytesDownload, totalBytesDownload,
            totalBytesExpectedToDownload) in
            
            // bytesDownload                   新增字节数
            // totalBytesDownload              本次下载接收的总字节数
            // totalBytesExpectedToDownload    本次下载的目标字节数
        }

        // 监听下载结果
        request.finishBlock = { (result, error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().downloadObject(request);
        
        // 取消下载
        // 如果需要取消下载，调用cancel方法
        request.cancel();
        
        //.cssg-snippet-body-end
      
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

    // 批量上传任务
    func batchUploadObjects() {
        
        //.cssg-snippet-body-start:[swift-batch-upload-objects]
        
        //.cssg-snippet-body-end

    }
    // .cssg-methods-pragma
        
    func testTransferObject() {
        // 高级接口上传对象
        self.transferUploadFile();
        // 高级接口上传二进制数据
        self.transferUploadBytes();
        // 高级接口流式上传
        self.transferUploadStream();
        // 高级接口下载对象
        self.transferDownloadObject();
        // 高级接口拷贝对象
        self.transferCopyObject();
        // 批量上传任务
        self.batchUploadObjects();
        // .cssg-methods-pragma
    }
}
