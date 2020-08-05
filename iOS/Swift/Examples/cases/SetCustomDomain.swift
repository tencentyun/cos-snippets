import XCTest
import QCloudCOSXML

class SetCustomDomain: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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
        cre.experationDate = DateFormatter().date(from: "expiredTime");
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


    // 设置默认加速域名
    func setCdnDomain() {
        //.cssg-snippet-body-start:[swift-set-cdn-domain]
        
        //.cssg-snippet-body-end
    }


    // 设置自定义加速域名
    func setCdnCustomDomain() {
        //.cssg-snippet-body-start:[swift-set-cdn-custom-domain]
        
        //.cssg-snippet-body-end
    }


    // 设置自定义域名
    func setCustomDomain() {
        //.cssg-snippet-body-start:[swift-set-custom-domain]
        
        //.cssg-snippet-body-end
    }


    // 设置全球加速域名
    func setAccelerateDomain() {
        //.cssg-snippet-body-start:[swift-set-accelerate-domain]
        
        //.cssg-snippet-body-end
    }


    // .cssg-methods-pragma

    func testSetCustomDomain() {
        // 设置默认加速域名
        self.setCdnDomain();
        // 设置自定义加速域名
        self.setCdnCustomDomain();
        // 设置自定义域名
        self.setCustomDomain();

        // 设置全球加速域名
        self.setAccelerateDomain();
        // .cssg-methods-pragma
    }
}
