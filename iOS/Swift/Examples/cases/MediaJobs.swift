import XCTest
import QCloudCOSXML

class MediaJobs: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
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

    /**
     * 查询指定任务
     */
    func GetMediaJob() {
        let request = QCloudGetMediaJobRequest()
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000"
        // 文件所在地域
        request.regionName = "regionName"
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.jobId = "jobId"
        request.finishBlock = { result, error in
            // result 查询指定任务 ，详细字段请查看 API 文档或者 SDK 源码
        }
        QCloudCOSXMLService.defaultCOSXML().getMediaJob(request)

    }
    
    /**
     * 获取符合条件的任务列表
     */
    func GetMediaJobList() {
        let request = QCloudGetMediaJobListRequest()
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000"
        // 文件所在地域
        request.regionName = "regionName"
        request.queueId = "queueId"
        request.queueType = "queueType"
        // ... 等参数
        request.finishBlock = { result, error in
            // result 查询指定任务 ，详细字段请查看 API 文档或者 SDK 源码
        }
        QCloudCOSXMLService.defaultCOSXML().getMediaJobList(request)

    }
    /**
     * 提交多任务处理
     */
    func CreateMediaJob() {
        let request = QCloudCreateMediaJobRequest()
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000"
        // 文件所在地域
        request.regionName = "regionName"
    
        request.finishBlock = { result, error in
            // result 精彩集锦 ，详细字段请查看 API 文档或者 SDK 源码
        }
        QCloudCOSXMLService.defaultCOSXML().createMediaJob(request)

    }
    
    
}
