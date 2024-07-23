import QCloudCOSXML
import XCTest
class DescribeFileMetaIndexDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testDescribeFileMetaIndex() {
		let request : QCloudDescribeFileMetaIndexRequest = QCloudDescribeFileMetaIndexRequest();
		request.regionName = "COS_REGIONNAME";
		// 数据集名称，同一个账户下唯一。;是否必传：true；
		request.datasetname = "数据集名称";
		// 资源标识字段，表示需要建立索引的文件地址，当前仅支持 COS 上的文件，字段规则：cos://<BucketName>/<ObjectKey>，其中BucketName表示 COS 存储桶名称，ObjectKey 表示文件完整路径，例如：cos://examplebucket-1250000000/test1/img.jpg。 注意： 仅支持本账号内的 COS 文件 不支持 HTTP 开头的地址 需 UrlEncode;是否必传：true；
		request.uri = "cos://facesearch-12500000000";
		request.finishBlock = { result, error in
			// result：QCloudDescribeFileMetaIndexResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106164
		};
		QCloudCOSXMLService.defaultCOSXML().describeFileMetaIndex(request);
	
	}

}