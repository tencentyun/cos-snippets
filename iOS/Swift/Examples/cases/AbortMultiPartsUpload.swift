import XCTest
import QCloudCOSXML

class AbortMultiPartsUpload: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
    var credentialFenceQueue:QCloudCredentailFenceQueue?;
    var uploadId : String?;
    
    
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
     * 作.分块上传适合于在弱网络或高带宽环境下上传较大的对象
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
                // 获取分块上传的 uploadId，后续的上传都需要这个 ID，请保存以备后续使用
                self.uploadId = result.uploadId;
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().initiateMultipartUpload(initRequest);
        
        //.cssg-snippet-body-end
    }
    
    
    /**
     * 终止分片上传任务
     *
     * 舍弃一个分块上传且删除已上传的分片块的方法.COS 支持舍弃一个分块上传且删除已上传的分片块.
     * 注意，已上传但是未终止的分片块会占用存储空间进 而产生存储费用.因此，建议及时完成分块上传
     * 或者舍弃分块上传.
     */
    func abortMultiUpload() {
        
        //.cssg-snippet-body-start:[swift-abort-multi-upload]
        let abort = QCloudAbortMultipfartUploadRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        abort.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        abort.object = "exampleobject";
        
        // 本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果
        // QCloudInitiateMultipartUploadResult 中得到
        abort.uploadId = self.uploadId!;
        
        abort.finishBlock = {(result,error)in
            if let result = result {
                // 可以从 result 中获取服务器返回的 header 信息
            } else {
                print(error!)
            }
        }
        QCloudCOSXMLService.defaultCOSXML().abortMultipfartUpload(abort);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testAbortMultiPartsUpload() {
        // 初始化分片上传
        self.initMultiUpload();
        // 终止分片上传任务
        self.abortMultiUpload();
        // .cssg-methods-pragma
    }
}
