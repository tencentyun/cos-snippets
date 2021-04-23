import XCTest
import QCloudCOSXML

class ListObjectsVersioning: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{
    
    var credentialFenceQueue:QCloudCredentailFenceQueue?;
    var prevPageResult:QCloudListVersionsResult?;
    
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
    
    
    // 获取对象多版本列表第一页数据
    func listObjectsVersioning() {
        //.cssg-snippet-body-start:[swift-list-objects-versioning]
        let listObjectVersionsRequest :QCloudListObjectVersionsRequest = QCloudListObjectVersionsRequest();
        
        // 存储桶名称，格式为 BucketName-APPID
        listObjectVersionsRequest.bucket = "examplebucket-1250000000";
        
        // 一次请求多少条数据
        listObjectVersionsRequest.maxKeys = 100;
        
        listObjectVersionsRequest.setFinish { (result, error) in
            
            self.prevPageResult = result;
            // result.deleteMarker; // 已删除的文件
            // result.versionContent;  对象版本条目
        }
        
        QCloudCOSXMLService.defaultCOSXML().listObjectVersions(listObjectVersionsRequest);
        //.cssg-snippet-body-end
    }
    
    
    // 获取对象多版本列表下一页数据
    func listObjectsVersioningNextPage() {
        //.cssg-snippet-body-start:[swift-list-objects-versioning-next-page]
        let listObjectVersionsRequest :QCloudListObjectVersionsRequest = QCloudListObjectVersionsRequest();
        
        // 存储桶名称，格式为 BucketName-APPID
        listObjectVersionsRequest.bucket = "examplebucket-1250000000";
        
        // 一页请求数据条目数
        listObjectVersionsRequest.maxKeys = 100;
        
        //从当前key列出剩余的条目
        listObjectVersionsRequest.keyMarker = prevPageResult!.nextKeyMarker;
        //从当前key的某个版本列出剩余的条目
        listObjectVersionsRequest.versionIdMarker = prevPageResult!.nextVersionIDMarkder;
        listObjectVersionsRequest.setFinish { (result, error) in

            // result.deleteMarker;
            // result.versionContent;  对象版本条目
        }
        
        QCloudCOSXMLService.defaultCOSXML().listObjectVersions(listObjectVersionsRequest);
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma
    
    
    func testListObjectsVersioning() {
        // 获取对象多版本列表第一页数据
        self.listObjectsVersioning();
        // 获取对象多版本列表下一页数据
        self.listObjectsVersioningNextPage();
        // .cssg-methods-pragma
    }
}
