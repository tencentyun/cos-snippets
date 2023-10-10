import QCloudCOSXML

class CreateCRcodeDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testCreateCRcode() {
			let request : QCloudCreateCRcodeRequest = QCloudCreateCRcodeRequest();
		request.bucket = "sample-1250000000";
		request.regionName = "COS_REGIONNAME";
		// 数据万象处理能力，二维码生成参数为 qrcode-generate;是否必传：true；
		request.ciProcess = "qrcode-generate";
		// 可识别的二维码文本信息;是否必传：true；
		request.qrcodeContent = ;
		// 生成的二维码类型，可选值：0或1。0为二维码，1为条形码，默认值为0;是否必传：false；
		request.mode = 0;
		// 指定生成的二维码或条形码的宽度，高度会进行等比压缩;是否必传：true；
		request.width = ;
		request.finishBlock = { result, error in
			// result：QCloudCreateCRcodeResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/53491
		};
		QCloudCOSXMLService.defaultCOSXML().createCRcode(request);
	
	}

}
