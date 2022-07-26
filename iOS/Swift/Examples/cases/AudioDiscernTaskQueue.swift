import XCTest
import QCloudCOSXML
class AudioDiscernTaskQueue: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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
        cre.expirationDate = DateFormatter().date(from: "expiredTime");
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

    // 查询存储桶是否已开通语音识别功能
    func getAudioDiscernOpenBucketList() {
        //.cssg-snippet-body-start:[swift-get-audiodiscern-bucketlist]
        
        let request = QCloudGetAudioDiscernOpenBucketListRequest.init();

        // 存储桶名称前缀，前缀搜索
        request.bucketName = "bucketName";

        request.regionName = "regionName";
        // 地域信息，以“,”分隔字符串，支持 All、ap-shanghai、ap-beijing
        request.regions = "regions";

        request.setFinish { outputObject, error in
            // outputObject 详细字段请查看api文档或者SDK源码
            // QCloudGetAudioOpenBucketListResult 类；
        }
        QCloudCOSXMLService.defaultCOSXML().getAudioDiscernOpenBucketList(request);
        
        //.cssg-snippet-body-end
    }

    // 查询语音识别队列
    func getAudioDiscernTaskQueue() {
        //.cssg-snippet-body-start:[swift-get-audiodiscern-taskqueue]
        let  request = QCloudGetAudioDiscernTaskQueueRequest.init();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        request.regionName = "regionName";
        // 队列 ID，以“,”符号分割字符串
        request.queueIds = "1,2,3";

        // 1. Active 表示队列内的作业会被语音识别服务调度执行
        // 2. Paused 表示队列暂停，作业不再会被语音识别服务调度执行，队列内的所有作业状态维持在暂停状态，已经处于识别中的任务将继续执行，不受影响
        request.state = 1;

        request.setFinish { outputObject, error in
            // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudAudioRecognitionResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().getAudioDiscernTaskQueue(request);
        //.cssg-snippet-body-end
    }
    
    // 更新语音识别队列
    func updateAudioDiscernTaskQueue() {
        //.cssg-snippet-body-start:[swift-update-audiodiscern-taskqueue]
        let request = QCloudUpdateAudioDiscernTaskQueueRequest.init();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        request.regionName = "regionName";
        // 模板名称
        request.name = "name";
        // 1. Active 表示队列内的作业会被语音识别服务调度执行
        // 2. Paused 表示队列暂停，作业不再会被语音识别服务调度执行，队列内的所有作业状态维持在暂停状态，已经处于识别中的任务将继续执行，不受影响
        request.state = 1;
        // 管道 ID
        request.queueID = "queueID";

        // 其他更多参数请查看sdk文档或源码注释

        request.setFinish { outputObject, error in
            // outputObject 详细字段请查看api文档或者SDK源码
            // QCloudAudioAsrqueueUpdateResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().updateAudioDiscernTaskQueue(request);
        //.cssg-snippet-body-end
    }
    
    // .cssg-methods-pragma

    func testAudioOperation() {
        // 查询存储桶是否已开通语音识别功能
        self.getAudioDiscernOpenBucketList();

        // 查询语音识别队列
        self.getAudioDiscernTaskQueue();
    
        // 更新语音识别队列
        self.updateAudioDiscernTaskQueue();
        // .cssg-methods-pragma
    }
}
