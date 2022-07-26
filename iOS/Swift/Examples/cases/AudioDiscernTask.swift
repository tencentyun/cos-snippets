import XCTest
import QCloudCOSXML
class AudioDiscernTask: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 提交一个语音识别任务
    func postAudioDiscernTask() {
        //.cssg-snippet-body-start:[swift-post-audiodiscern]
        let request = QCloudPostAudioDiscernTaskRequest.init();

       // 存储桶名称，格式为 BucketName-APPID
       request.bucket = "BucketName-APPID";
       request.regionName = "regionName";

       let taskInfo = QCloudPostAudioDiscernTaskInfo.init();
       taskInfo.tag = "SpeechRecognition";
       
       // 队列 ID ,通过查询语音识别队列获取
       taskInfo.queueId = "QueueId";
       // 操作规则
       let input = QCloudPostAudioDiscernTaskInfoInput.init();
       input.object = "test1";
       // 待操作的语音文件
       taskInfo.input = input;
       let op = QCloudPostAudioDiscernTaskInfoOperation.init();
       let output = QCloudPostAudioDiscernTaskInfoOutput.init();
       output.region = "regionName";
       output.bucket = "BucketName-APPID";
       output.object = "test";
       // 结果输出地址
       op.output = output;

       let speechRecognition = QCloudPostAudioDiscernTaskInfoSpeechRecognition.init();
       speechRecognition.engineModelType = "16k_zh";
       speechRecognition.channelNum = 1;
       speechRecognition.resTextFormat = 0;
       speechRecognition.convertNumMode = 0;
       // 当 Tag 为 SpeechRecognition 时有效，指定该任务的参数
       op.speechRecognition = speechRecognition;
       // 操作规则
       taskInfo.operation = op;
       //  语音识别任务
       request.taskInfo = taskInfo;

        request.setFinish { outputObject, error in
            // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudPostAudioRecognitionResult 类；
        };
       QCloudCOSXMLService.defaultCOSXML().postAudioDiscernTask(request);
        
        //.cssg-snippet-body-end
    }

    // 查询指定的语音识别任务
    func getAudioDiscernTask() {
        //.cssg-snippet-body-start:[swift-get-audiodiscern-task]
        let request = QCloudGetAudioDiscernTaskRequest.init();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // QCloudPostAudioDiscernTaskRequest接口返回的jobid
        request.jobId = "jobid";

        request.regionName = "regionName";

        request.setFinish { outputObject, error in
            // outputObject 详细字段请查看api文档或者SDK源码
            // QCloudGetAudioDiscernTaskResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().getAudioDiscernTask(request);
        //.cssg-snippet-body-end
    }
    
    // 批量拉取语音识别任务
    func batchGetAudioDiscernTask() {
        //.cssg-snippet-body-start:[swift-batch-audiodiscern-task]
        let request = QCloudBatchGetAudioDiscernTaskRequest.init();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // 拉取该队列 ID 下的任务。
        // 通过查询语音识别队列获取
        request.queueId = "queueId";

        request.regionName = "regionName";

        request.states = QCloudTaskStatesEnum(rawValue: QCloudTaskStatesEnum.success.rawValue | QCloudTaskStatesEnum.cancel.rawValue)!;

        // 其他更多参数请查阅sdk文档或源码注释

        request.setFinish { outputObject, error in
            // outputObject 任务结果，详细字段请查看api文档或者SDK源码
            // QCloudBatchGetAudioDiscernTaskResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().batchGetAudioDiscernTask(request);
        //.cssg-snippet-body-end
    }
    
    // .cssg-methods-pragma
    func testAudioOperation() {
        // 提交一个语音识别任务
        self.postAudioDiscernTask();

        // 查询指定的语音识别任务
        self.getAudioDiscernTask();
        
        // 批量拉取语音识别任务
        self.batchGetAudioDiscernTask();
    
        // .cssg-methods-pragma
    }
}
