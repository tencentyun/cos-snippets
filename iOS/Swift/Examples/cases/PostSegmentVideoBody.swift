import XCTest
import QCloudCOSXML

class PostSegmentVideoBodyDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testPostSegmentVideoBody() {
			let request : QCloudPostSegmentVideoBodyRequest = QCloudPostSegmentVideoBodyRequest();
		request.bucket = "sample-1250000000";
		request.regionName = "COS_REGIONNAME";
		let postSegmentVideoBody : QCloudPostSegmentVideoBody = QCloudPostSegmentVideoBody();
		// 创建任务的 Tag：SegmentVideoBody;是否必传：是
		request.input.tag = "";
		// 待操作的对象信息;是否必传：是
		let input : QCloudPostSegmentVideoBodyInput = QCloudPostSegmentVideoBodyInput();
		// 文件路径;是否必传：是
        request.input.input.object = "";
		// 操作规则;是否必传：是
		let operation : QCloudPostSegmentVideoBodyOperation = QCloudPostSegmentVideoBodyOperation();
		// 视频人像抠图配置;是否必传：否
		let segmentVideoBody : QCloudPostSegmentVideoBodySegmentVideoBody = QCloudPostSegmentVideoBodySegmentVideoBody();
		// 结果输出配置;是否必传：是
		let output : QCloudPostSegmentVideoBodyOutput = QCloudPostSegmentVideoBodyOutput();
		// 存储桶的地域;是否必传：是
        request.input.operation.output.region = "";
		// 存储结果的存储桶;是否必传：是
        request.input.operation.output.bucket = "";
		// 输出结果的文件名;是否必传：是
        request.input.operation.output.object = "";
		request.finishBlock = { result, error in
			// result：QCloudPostSegmentVideoBodyResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/83973
		};
		QCloudCOSXMLService.defaultCOSXML().postSegmentVideoBody(request);
	
	}

}
