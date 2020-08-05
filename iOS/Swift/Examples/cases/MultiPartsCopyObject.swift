import XCTest
import QCloudCOSXML

class MultiPartsCopyObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
    var credentialFenceQueue:QCloudCredentailFenceQueue?;
    var uploadId : String?;
    var parts :Array<QCloudMultipartInfo>?;
    
    
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
     * 初始化分块上传的方法
     *
     * 使用分块上传对象时，首先要进行初始化分片上传操作，获取对应分块上传的 uploadId，用于后续上传操
     * 作.分块上传适合于在弱网络或高带宽环境下上传较大的对象.SDK 支持自行切分对象并分别调用
     * uploadPart(UploadPartRequest)或者
     * uploadPartAsync(UploadPartRequest, CosXmlResultListener)上传各 个分块.
     */
    func initMultiUpload() {
        //.cssg-snippet-body-start:[swift-init-multi-upload]
        let initRequest = QCloudInitiateMultipartUploadRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        initRequest.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        initRequest.object = "exampleobject";
        
        initRequest.setFinish { (result, error) in
            if let result = result {
                // 获取分块拷贝的 uploadId，后续的上传都需要这个 ID，请保存以备后续使用
                self.uploadId = result.uploadId;
            } else {
                print(error!);
            }
        }
        
        // 初始化上传
        QCloudCOSXMLService.defaultCOSXML().initiateMultipartUpload(initRequest);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * COS 中复制对象可以完成如下功能:
     * 创建一个新的对象副本.
     * 复制对象并更名，删除原始对象，实现重命名
     * 修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.
     * 在不同的腾讯云 COS 地域复制对象.修改对象的元数据，在复制时选择相同的源和目标对象键，
     * 并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.
     */
    func uploadPartCopy() {
        //.cssg-snippet-body-start:[swift-upload-part-copy]
        let req = QCloudUploadPartCopyRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        req.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        req.object = "exampleobject";
        
        // 源文件 URL 路径，可以通过 versionid 子资源指定历史版本
        req.source = "sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject";
        // 在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
        if let uploadId = self.uploadId {
            req.uploadID = uploadId;
        }
        
        // 标志当前分块的序号
        req.partNumber = 1;
        req.setFinish { (result, error) in
            if let result = result {
                let mutipartInfo = QCloudMultipartInfo.init();
                // 获取所复制分块的 etag
                mutipartInfo.eTag = result.eTag;
                mutipartInfo.partNumber = "1";
                // 保存起来用于最后完成复制时使用
                self.parts = [mutipartInfo];
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().uploadPartCopy(req);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * 当使用分块上传（uploadPart(UploadPartRequest)）完对象的所有块以后，必须调用该
     * completeMultiUpload(CompleteMultiUploadRequest) 或者
     * completeMultiUploadAsync(CompleteMultiUploadRequest, CosXmlResultListener)
     * 来完成整个文件的分块上传.且在该请求的 Body 中需要给出每一个块的 PartNumber 和 ETag，
     * 用来校验块的准 确性.
     */
    func completeMultiUpload() {
        //.cssg-snippet-body-start:[swift-complete-multi-upload]
        let  complete = QCloudCompleteMultipartUploadRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        complete.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        complete.object = "exampleobject";
        
        // 本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果
        // QCloudInitiateMultipartUploadResult 中得到
        if let uploadId = self.uploadId {
            complete.uploadId = uploadId;
        }
        
        // 在进行HTTP请求的时候，可以通过设置该参数来设置自定义的一些头部信息。
        // 通常情况下，携带特定的额外HTTP头部可以使用某项功能，如果是这类需求
        // 可以通过设置该属性来实现。
        complete.customHeaders.setValue("", forKey: "");
        // 已上传分块的信息
        let completeInfo = QCloudCompleteMultipartUploadInfo.init();
        if self.parts == nil {
            print("没有要完成的分块");
            return;
        }
        
        completeInfo.parts = self.parts!;
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
    
    
    func testMultiPartsCopyObject() {
        // 初始化分片上传
        self.initMultiUpload();
        // 拷贝一个分片
        self.uploadPartCopy();
        // 完成分片拷贝任务
        self.completeMultiUpload();
        // .cssg-methods-pragma
    }
}
