import XCTest
import QCloudCOSXML

class PostVoiceSynthesisDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testPostVoiceSynthesis() {
			let request : QCloudPostVoiceSynthesisRequest = QCloudPostVoiceSynthesisRequest();
		request.bucket = "sample-1250000000";
		request.regionName = "COS_REGIONNAME";
		let postVoiceSynthesis : QCloudPostVoiceSynthesis = QCloudPostVoiceSynthesis();
		// 创建任务的 Tag：Tts;是否必传：是
		request.input.tag = "";
		// 操作规则;是否必传：是
		let operation : QCloudPostVoiceSynthesisOperation = QCloudPostVoiceSynthesisOperation();
		// 语音合成参数;是否必传：否
		let ttsTpl : QCloudPostVoiceSynthesisTtsTpl = QCloudPostVoiceSynthesisTtsTpl();
		// 语音合成任务参数;是否必传：是
		let ttsConfig : QCloudPostVoiceSynthesisTtsConfig = QCloudPostVoiceSynthesisTtsConfig();
		// 输入类型，Url/Text;是否必传：是
		request.input.operation.ttsConfig.inputType = "";
		// 当 InputType 为 Url 时， 必须是合法的 COS 地址，文件必须是utf-8编码，且大小不超过 10M。如果合成方式为同步处理，则文件内容不超过 300 个 utf-8 字符；如果合成方式为异步处理，则文件内容不超过 10000 个 utf-8 字符。当 InputType 为 Text 时, 输入必须是 utf-8 字符, 且不超过 300 个字符。;是否必传：是
		request.input.operation.ttsConfig.input = "";
		// 结果输出配置;是否必传：是
		let output : QCloudPostVoiceSynthesisOutput = QCloudPostVoiceSynthesisOutput();
		// 存储桶的地域;是否必传：是
		request.input.operation.output.region = "";
		// 存储结果的存储桶;是否必传：是
		request.input.operation.output.bucket = "";
		// 结果文件名;是否必传：是
		request.input.operation.output.object = "";
		request.finishBlock = { result, error in
			// result：QCloudPostVoiceSynthesisResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/84797
		};
		QCloudCOSXMLService.defaultCOSXML().postVoiceSynthesis(request);
	
	}

}
