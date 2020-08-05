import XCTest
import QCloudCOSXML

class TransferUploadObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 高级接口上传对象
    func transferUploadFile() {
        //.cssg-snippet-body-start:[swift-transfer-upload-file]
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        
        // 存储桶名称，格式为 BucketName-APPID
        put.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        
        // 需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
        put.body = NSURL.fileURL(withPath: "Local File Path") as AnyObject;
        
        // 监听上传结果
        put.setFinish { (result, error) in
            // 获取上传结果
            if let result = result {
                // 文件的 etag
                let eTag = result.eTag
            } else {
                print(error!);
            }
        }

        // 监听上传进度
        put.sendProcessBlock = { (bytesSent, totalBytesSent,
            totalBytesExpectedToSend) in
            // bytesSent                   新增字节数
            // totalBytesSent              本次上传的总字节数
            // totalBytesExpectedToSend    本地上传的目标字节数
        };
        // 设置上传参数
        put.initMultipleUploadFinishBlock = {(multipleUploadInitResult, resumeData) in
            // 在初始化分块上传完成以后会回调该 block，在这里可以获取 resumeData,以及 uploadId
            if let multipleUploadInitResult = multipleUploadInitResult {
                let uploadId = multipleUploadInitResult.uploadId
            }
        }
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
        
        //.cssg-snippet-body-end
    }
    
    
    // 高级接口上传二进制数据
    func transferUploadBytes() {
        
        //.cssg-snippet-body-start:[swift-transfer-upload-bytes]
        
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        
        // 存储桶名称，格式为 BucketName-APPID
        put.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        put.object = "exampleobject";
        
        // 需要上传的对象内容
        let dataBody:NSData = "wrwrwrwrwrw".data(using: .utf8)! as NSData;
        put.body = dataBody;
        
        // 监听上传结果
        put.setFinish { (result, error) in
            // 获取上传结果
            if let result = result {
                // 文件的 etag
                let eTag = result.eTag
            } else {
                print(error!);
            }
        }

        // 监听上传进度
        put.sendProcessBlock = { (bytesSent, totalBytesSent,
            totalBytesExpectedToSend) in
            
            // bytesSent                   新增字节数
            // totalBytesSent              本次上传的总字节数
            // totalBytesExpectedToSend    本地上传的目标字节数
        };
        
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
        //.cssg-snippet-body-end
    }


    // 高级接口流式上传
    func transferUploadStream() {
        //.cssg-snippet-body-start:[swift-transfer-upload-stream]
        
        //.cssg-snippet-body-end
    }


    // 批量上传
    func transferBatchUploadObjects() {
        //.cssg-snippet-body-start:[swift-transfer-batch-upload-objects]
        
        //.cssg-snippet-body-end
    }


    // 上传暂停、续传、取消
    func transferUploadInteract() {
        //.cssg-snippet-body-start:[swift-transfer-upload-pause]
        
        //.cssg-snippet-body-end
        
        //.cssg-snippet-body-start:[swift-transfer-upload-resume]
        
        //.cssg-snippet-body-end
        
        //.cssg-snippet-body-start:[swift-transfer-upload-cancel]
        
        //.cssg-snippet-body-end
    }


    // 高级接口 URI 上传
    func transferUploadUri() {
        //.cssg-snippet-body-start:[swift-transfer-upload-uri]
        
        //.cssg-snippet-body-end
    }



    // .cssg-methods-pragma

    func testTransferUploadObject() {
        // 高级接口上传对象
        self.transferUploadFile();
        // 高级接口上传二进制数据
        self.transferUploadBytes();
        // 高级接口流式上传
        self.transferUploadStream();
        // 上传暂停、续传、取消
        self.transferUploadInteract();
        // 批量上传
        self.transferBatchUploadObjects();

        // 高级接口 URI 上传
        self.transferUploadUri();
        
        // .cssg-methods-pragma
    }
}
