import XCTest
import QCloudCOSXML

class QrcodeRecognition: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    // 下载时进行二维码识别
    func downloadWithQrcodeRecognition() {
        //.cssg-snippet-body-start:[swift-download-with-qrcode-recognition]
        let put = QCloudQRCodeRecognitionRequest();
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        // 存储桶名称，格式为 BucketName-APPID
        
        put.bucket = "examplebucket-1250000000";
        let op = QCloudPicOperations.init();
        
        // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
        op.is_pic_info = false;
        
        let rule = QCloudPicOperationRule.init();
        
        // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
        
        rule.fileid = "test";
        
        // 二维码识别的rule
        rule.rule = "QRcode/cover/1";

        op.rule = [rule];
        put.picOperations = op;
        put.setFinish { (outoutObject, error) in
            
        };
        QCloudCOSXMLService.defaultCOSXML().ciqrCodeRecognition(put);
        //.cssg-snippet-body-end
    }

    // .cssg-methods-pragma

    func testQrcodeRecognition() {

        // 下载时进行二维码识别
        self.downloadWithQrcodeRecognition();
        // .cssg-methods-pragma
    }
}
