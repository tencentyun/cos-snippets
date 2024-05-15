import XCTest
import QCloudCOSXML

class VocalScoreDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testVocalScore() {
        let request : QCloudVocalScoreRequest = QCloudVocalScoreRequest();
        request.bucket = "sample-1250000000";
        request.regionName = "COS_REGIONNAME";
        let vocalScore : QCloudVocalScore = QCloudVocalScore();
        // 创建任务的 Tag：VocalScore;是否必传：是
        request.input.tag = "";
        // 待操作的对象信息;是否必传：是
        let input : QCloudVocalScoreInput = QCloudVocalScoreInput();
        // 操作规则;是否必传：是
        let operation : QCloudVocalScoreOperation = QCloudVocalScoreOperation();
        // 任务回调TDMQ配置，当 CallBackType 为 TDMQ 时必填。详情见 CallBackMqConfig;是否必传：否
        let callBackMqConfig : QCloudCallBackMqConfig = QCloudCallBackMqConfig();
        // 消息队列所属园区，目前支持园区 sh（上海）、bj（北京）、gz（广州）、cd（成都）、hk（中国香港）;是否必传：是
        request.input.callBackMqConfig.mqRegion = "";
        // 消息队列使用模式，默认 Queue ：主题订阅：Topic队列服务: Queue;是否必传：是
        request.input.callBackMqConfig.mqMode = "";
        // TDMQ 主题名称;是否必传：是
        request.input.callBackMqConfig.mqName = "";


        request.finishBlock = { result, error in
         // result：QCloudVocalScoreResponse 包含所有的响应；
         // 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/96095
         // outputObject返回JobId，使用QCloudGetMediaJobRequest 查询结果
        };
        QCloudCOSXMLService.defaultCOSXML().vocalScore(request);

	
	}

}
