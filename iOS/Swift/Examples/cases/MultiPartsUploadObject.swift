import XCTest
import QCloudCOSXML

class MultiPartsUploadObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
    var credentialFenceQueue:QCloudCredentailFenceQueue?;
    
    var uploadId : String?;
    
    var parts : Array<QCloudMultipartInfo>?;
    
    
    
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
    
    
    // 初始化分片上传
    func initMultiUpload() {
        //.cssg-snippet-body-start:[swift-init-multi-upload]
        let initRequest = QCloudInitiateMultipartUploadRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        initRequest.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        initRequest.object = "exampleobject";
        
        initRequest.setFinish { (result, error) in
            if let result = result {
                // 获取分块上传的 uploadId，后续的上传都需要这个 ID，请保存以备后续使用
                self.uploadId = result.uploadId;
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().initiateMultipartUpload(initRequest);
        
        //.cssg-snippet-body-end
    }
    
    
    // 列出所有未完成的分片上传任务
    func listMultiUpload() {
        //.cssg-snippet-body-start:[swift-list-multi-upload]
        let listParts = QCloudListBucketMultipartUploadsRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        listParts.bucket = "examplebucket-1250000000";
        
        // 设置最大返回的 multipart 数量，合法取值从 1 到 1000
        listParts.maxUploads = 100;
        
        listParts.setFinish { (result, error) in
            if let result = result {
                // 未完成的所有分块上传任务
                let uploads = result.uploads;
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().listBucketMultipartUploads(listParts);
        
        //.cssg-snippet-body-end
    }
    
    
    // 上传一个分片
    func uploadPart() {
        //.cssg-snippet-body-start:[swift-upload-part]
        let uploadPart = QCloudUploadPartRequest<AnyObject>.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        uploadPart.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        uploadPart.object = "exampleobject";
        uploadPart.partNumber = 1;
        
        // 标识本次分块上传的 ID
        if let uploadId = self.uploadId {
            uploadPart.uploadId = uploadId;
        }
        
        // 示例文件内容
        let dataBody:NSData? = "wrwrwrwrwrwwrwrwrwrwrwwwrwrw"
            .data(using: .utf8) as NSData?;
        
        uploadPart.body = dataBody!;
        uploadPart.setFinish { (result, error) in
            if let result = result {
                let mutipartInfo = QCloudMultipartInfo.init();
                // 获取分块的 etag
                mutipartInfo.eTag = result.eTag;
                mutipartInfo.partNumber = "1";
                // 保存起来用于最后完成上传时使用
                self.parts = [mutipartInfo];
            } else {
                print(error!);
            }
        }
        uploadPart.sendProcessBlock = {(bytesSent,totalBytesSent,
                                        totalBytesExpectedToSend) in
            // 上传进度信息
            // bytesSent                   新增字节数
            // totalBytesSent              本次上传的总字节数
            // totalBytesExpectedToSend    本地上传的目标字节数
            
        }
        QCloudCOSXMLService.defaultCOSXML().uploadPart(uploadPart);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * 查询存储桶（Bucket）中正在进行中的分块上传对象的方法.
     *
     * COS 支持查询 Bucket 中有哪些正在进行中的分块上传对象，单次请求操作最多列出 1000 个正在进行中的 分块上传对象.
     */
    func listParts() {
        //.cssg-snippet-body-start:[swift-list-parts]
        let req = QCloudListMultipartRequest.init();
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        req.object = "exampleobject";
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        
        // 在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
        if let uploadId = self.uploadId {
            req.uploadId = uploadId;
        }
        req.setFinish { (result, error) in
            if let result = result {
                // 所有已完成的分片
                let parts = result.parts
            } else {
                print(error!);
            }
        }
        
        QCloudCOSXMLService.defaultCOSXML().listMultipart(req);
        
        //.cssg-snippet-body-end
    }
    
    
    // 完成分片上传任务
    func completeMultiUpload() {
        //.cssg-snippet-body-start:[swift-complete-multi-upload]
        let  complete = QCloudCompleteMultipartUploadRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        complete.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        complete.object = "exampleobject";
        
        // 本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果
        // QCloudInitiateMultipartUploadResult 中得到
        complete.uploadId = "exampleUploadId";
        if let uploadId = self.uploadId {
            complete.uploadId = uploadId;
        }
        
        // 已上传分块的信息
        let completeInfo = QCloudCompleteMultipartUploadInfo.init();
        if self.parts == nil {
            print("没有要完成的分块");
            return;
        }
        if self.parts != nil {
            completeInfo.parts = self.parts ?? [];
        }
        
        complete.parts = completeInfo;
        complete.setFinish { (result, error) in
            if let result = result {
                // 文件的 eTag
                let eTag = result.eTag
                // 不带签名的文件链接
                let location = result.location
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().completeMultipartUpload(complete);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testMultiPartsUploadObject() {
        // 初始化分片上传
        self.initMultiUpload();
        // 列出所有未完成的分片上传任务
        self.listMultiUpload();
        // 上传一个分片
        self.uploadPart();
        // 列出已上传的分片
        self.listParts();
        // 完成分片上传任务
        self.completeMultiUpload();
        // .cssg-methods-pragma
    }
}
