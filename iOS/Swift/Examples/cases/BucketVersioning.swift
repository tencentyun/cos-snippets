import XCTest
import QCloudCOSXML

class BucketVersioning: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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
        cre.experationDate = DateFormatter().date(from: "expiredTime");
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


    /**
    * 启用或者暂停存储桶的版本控制功能
    *
    * 1:如果您从未在存储桶上启用过版本控制，则 GET Bucket versioning 请求不返回版本状态值。
    * 2:开启版本控制功能后，只能暂停，不能关闭。
    * 3:设置版本控制状态值为 Enabled 或者 Suspended，表示开启版本控制和暂停版本控制。
    * 4:设置存储桶的版本控制功能，您需要有存储桶的写权限。
    */
    func putBucketVersioning() {
        //.cssg-snippet-body-start:[swift-put-bucket-versioning]
        // 开启版本控制
        let putBucketVersioning = QCloudPutBucketVersioningRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putBucketVersioning.bucket = "examplebucket-1250000000";
        
        // 说明版本控制的具体信息
        let config = QCloudBucketVersioningConfiguration.init();
        
        // 说明版本是否开启，枚举值：Suspended、Enabled
        config.status = .enabled;
        
        putBucketVersioning.configuration = config;
        
        putBucketVersioning.finishBlock = {(result,error) in
            if let result = result {
                // result 包含响应的 header 信息
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketVersioning(putBucketVersioning);
        
        //.cssg-snippet-body-end
    }


    /**
    *  接口用于实现获得存储桶的版本控制信息
    *
    *  细节分析
    *  1:获取存储桶版本控制的状态，需要有该存储桶的读权限。
    *  2:有三种版本控制状态：未启用版本控制、启用版本控制和暂停版本控制。
    */
    func getBucketVersioning() {
        //.cssg-snippet-body-start:[swift-get-bucket-versioning]
        let getBucketVersioning = QCloudGetBucketVersioningRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        getBucketVersioning.bucket = "examplebucket-1250000000";
        
        getBucketVersioning.setFinish { (config, error) in
            if let config = config {
                // 多版本状态
                let status = config.status
            } else {
                print(error!);
            }
               
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketVersioning(getBucketVersioning);
        
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    func testBucketVersioning() {
        // 设置存储桶多版本
        self.putBucketVersioning();
        // 获取存储桶多版本状态
        self.getBucketVersioning();
        // .cssg-methods-pragma
    }
}
