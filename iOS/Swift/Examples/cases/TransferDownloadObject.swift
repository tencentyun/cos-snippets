import XCTest
import QCloudCOSXML

class TransferDownloadObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 高级接口下载对象
    func transferDownloadObject() {
        //.cssg-snippet-body-start:[swift-transfer-download-object]
        let request : QCloudCOSXMLDownloadObjectRequest = QCloudCOSXMLDownloadObjectRequest();
        
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";
        
        // 设置下载的路径 URL，如果设置了，文件将会被下载到指定路径中
        request.downloadingURL = NSURL.fileURL(withPath: "Local File Path") as URL?;
        
        // 本地已下载的文件大小，如果是从头开始下载，请不要设置
        request.localCacheDownloadOffset = 100;

        // 监听下载进度
        request.sendProcessBlock = { (bytesDownload, totalBytesDownload,
            totalBytesExpectedToDownload) in
            
            // bytesDownload                   新增字节数
            // totalBytesDownload              本次下载接收的总字节数
            // totalBytesExpectedToDownload    本次下载的目标字节数
        }

        // 监听下载结果
        request.finishBlock = { (result, error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().downloadObject(request);
        
        //.cssg-snippet-body-end
    }


    // 批量下载
    func transferBatchDownloadObjects() {
        //.cssg-snippet-body-start:[swift-transfer-batch-download-objects]
        
        //.cssg-snippet-body-end
    }


    // 下载暂停、续传、取消
    func transferDownloadObjectInteract() {
        //.cssg-snippet-body-start:[swift-transfer-download-object-pause]
        
        //.cssg-snippet-body-end
        
        //.cssg-snippet-body-start:[swift-transfer-download-object-resume]
        
        //.cssg-snippet-body-end
        
        //.cssg-snippet-body-start:[swift-transfer-download-object-cancel]
        
        //.cssg-snippet-body-end
    }


    // .cssg-methods-pragma

    func testTransferDownloadObject() {
        // 高级接口下载对象
        self.transferDownloadObject();
        // 下载暂停、续传、取消
        self.transferDownloadObjectInteract();
        // 批量下载
        self.transferBatchDownloadObjects();
        
        // .cssg-methods-pragma
    }
}
