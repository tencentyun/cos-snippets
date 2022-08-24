import XCTest
import QCloudCOSXML
class WordsGeneralizeTask: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 提交一个分词任务
    func postWordsGeneralizeTask() {
        
        let request = QCloudPostWordsGeneralizeTaskRequest.init();
    
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        request.regionName = "regionName";
        // 创建分词任务对象
        let taskInfo = QCloudWordsGeneralizeInput.init();
    
        // 设置要处理的文件
        taskInfo.input = QCloudWordsGeneralizeInputObject.init();
        taskInfo.input.object = "aaa.m4a";
        
        taskInfo.tag = "WordsGeneralize";
        taskInfo.queueId = "queueId";
        //  分词任务
        request.taskInfo = taskInfo;

        request.setFinish { outputObject, error in
            // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudWordsGeneralizeResult 类；
        };
        QCloudCOSXMLService.defaultCOSXML().postWordsGeneralizeTask(request);
    }

    // 查询指定的分词任务
    func getWordsGeneralizeTask() {
        let request = QCloudGetWordsGeneralizeRequest.init();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // QCloudPostWordsGeneralizeRequest接口返回的jobid
        request.jobId = "jobid";

        request.regionName = "regionName";

        request.setFinish { outputObject, error in
            // outputObject 详细字段请查看api文档或者SDK源码
            // QCloudWordsGeneralizeResult 类；
        };

        QCloudCOSXMLService.defaultCOSXML().getWordsGeneralizeTask(request);
    }
    
    // .cssg-methods-pragma
    func testWordsGeneralizeOperation() {
        // 提交一个语音识别任务
        self.postWordsGeneralizeTask();

        // 查询指定的分词任务
        self.getWordsGeneralizeTask();
    
        // .cssg-methods-pragma
    }
}
