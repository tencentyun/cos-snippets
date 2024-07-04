import QCloudCOSXML
import XCTest
class SearchImageDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testSearchImage() {
		let request : QCloudSearchImageRequest = QCloudSearchImageRequest();
		request.regionName = "COS_REGIONNAME";
		request.input = QCloudSearchImage();
		// 数据集名称，同一个账户下唯一。;是否必传：是
		request.input.datasetName = "ImageSearch001";
		// 指定检索方式为图片或文本，pic 为图片检索，text 为文本检索，默认为 pic。;是否必传：否
		request.input.mode = "pic";
		// 资源标识字段，表示需要建立索引的文件地址(Mode 为 pic 时必选)。;是否必传：否
		request.input.uri = "cos://facesearch-1258726280/huge_base.jpg";
		// 返回相关图片的数量，默认值为10，最大值为100。;是否必传：否
		request.input.limit = 10;
		// 出参 Score（相关图片匹配得分） 中，只有超过 MatchThreshold 值的结果才会返回。默认值为0，推荐值为80。;是否必传：否
		request.input.matchThreshold = 1;
		request.finishBlock = { result, error in
			// result：QCloudSearchImageResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106376
		};
		QCloudCOSXMLService.defaultCOSXML().searchImage(request);
	
	}

}
