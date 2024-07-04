import QCloudCOSXML
import XCTest
class DeleteFileMetaIndexDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testDeleteFileMetaIndex() {
		let request : QCloudDeleteFileMetaIndexRequest = QCloudDeleteFileMetaIndexRequest();
		request.regionName = "COS_REGIONNAME";
		request.input = QCloudDeleteFileMetaIndex();
		// 数据集名称，同一个账户下唯一。;是否必传：是
		request.input.datasetName = "test";
		// 资源标识字段，表示需要建立索引的文件地址。;是否必传：是
		request.input.uri = "cos://examplebucket-1250000000/test.jpg";
		request.finishBlock = { result, error in
			// result：QCloudDeleteFileMetaIndexResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106163
		};
		QCloudCOSXMLService.defaultCOSXML().deleteFileMetaIndex(request);
	
	}

}
