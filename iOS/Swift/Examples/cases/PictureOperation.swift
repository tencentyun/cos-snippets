import XCTest
import QCloudCOSXML

class PictureOperation: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 上传时图片处理
    func uploadWithPicOperation() {
        //.cssg-snippet-body-start:[swift-upload-with-pic-operation]
        
        //.cssg-snippet-body-end
    }


    // 对云上数据进行图片处理
    func processWithPicOperation() {
        //.cssg-snippet-body-start:[swift-process-with-pic-operation]
        
        //.cssg-snippet-body-end
    }


    // 上传时添加盲水印
    func putObjectWithWatermark() {
        //.cssg-snippet-body-start:[swift-put-object-with-watermark]
        
        //.cssg-snippet-body-end
    }


    // 下载时添加盲水印
    func downloadObjectWithWatermark() {
        //.cssg-snippet-body-start:[swift-download-object-with-watermark]
        
        //.cssg-snippet-body-end
    }


    // 图片审核
    func sensitiveContentRecognition() {
        //.cssg-snippet-body-start:[swift-sensitive-content-recognition]
        
        //.cssg-snippet-body-end
    }


    // .cssg-methods-pragma

    func testPictureOperation() {
        // 上传时图片处理
        self.uploadWithPicOperation();

        // 对云上数据进行图片处理
        self.processWithPicOperation();
        // 上传时添加盲水印
        self.putObjectWithWatermark();
        // 下载时添加盲水印
        self.downloadObjectWithWatermark();
        // 图片审核
        self.sensitiveContentRecognition();
        // .cssg-methods-pragma
    }
}
