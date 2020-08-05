import XCTest
import QCloudCOSXML

class CopyObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 复制对象时保留对象属性
    func copyObject() {
        //.cssg-snippet-body-start:[swift-copy-object]
        let putObjectCopy = QCloudPutObjectCopyRequest.init();
        
        // 存储桶名称，格式为 BucketName-APPID
        putObjectCopy.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        putObjectCopy.object = "exampleobject";
        
        // 源对象所在的路径
        putObjectCopy.objectCopySource = "sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject";
        
        // 是否拷贝元数据，枚举值：Copy，Replaced，默认值 Copy。
        // 假如标记为 Copy，忽略 Header 中的用户元数据信息直接复制
        // 假如标记为 Replaced，按 Header 信息修改元数据。当目标路径和原路径一致，即用户试图修改元数据时，必须为 Replaced
        putObjectCopy.metadataDirective = "Copy";
        
        // 定义 Object 的 ACL 属性，有效值：private，public-read，default。
        // 默认值：default（继承 Bucket 权限）。
        // 注意：当前访问策略条目限制为1000条，如果您无需进行 Object ACL 控制，请填 default
        // 或者此项不进行设置，默认继承 Bucket 权限。
        putObjectCopy.accessControlList = "default";
        
        // 指定源文件的 versionID，只有开启或开启后暂停的存储桶，才会响应此参数
        putObjectCopy.versionID = "versionID";
        
        putObjectCopy.setFinish { (result, error) in
            if let result = result {
                let eTag = result.eTag
            } else {
                print(error!);
            }
        }
        QCloudCOSXMLService.defaultCOSXML().putObjectCopy(putObjectCopy);
        
        //.cssg-snippet-body-end
    }


    // 复制对象时替换对象属性
    func copyObjectReplaced() {
        //.cssg-snippet-body-start:[swift-copy-object-replaced]
        let request : QCloudPutObjectCopyRequest  = QCloudPutObjectCopyRequest();
        
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";
        
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";
        
        // 是否拷贝元数据，枚举值：Copy，Replaced，默认值 Copy。
        // 假如标记为 Copy，忽略 Header 中的用户元数据信息直接复制
        // 假如标记为 Replaced，按 Header 信息修改元数据。当目标路径和原路径一致，即用户试图修改元数据时，必须为 Replaced
        request.metadataDirective = "Replaced";
        
        // 修改元数据
        request.customHeaders.setValue("newValue", forKey: "x-cos-meta-*");
        
        // 对象存储类型，枚举值请参见 存储类型 文档，例如 MAZ_STANDARD，MAZ_STANDARD_IA，
        // STANDARD_IA，ARCHIVE。仅当对象不是标准存储（STANDARD）时才会返回该头部
        // 修改存储类型
        request.customHeaders.setValue("newValue", forKey: "x-cos-storage-class");
        
        // 定义 Object 的 ACL 属性，有效值：private，public-read，default。
        // 默认值：default（继承 Bucket 权限）。
        // 注意：当前访问策略条目限制为1000条，如果您无需进行 Object ACL 控制，请填 default
        // 或者此项不进行设置，默认继承 Bucket 权限。
        // 修改acl
        request.accessControlList = "源文件acl";
        // 源对象所在的路径
        request.objectCopySource = "sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject";
        
        // 指定源文件的 versionID，只有开启或开启后暂停的存储桶，才会响应此参数
        request.versionID = "versionID";
        
        request.setFinish { (result, error) in
            if let result = result {
                let eTag = result.eTag
            } else {
                print(error!);
            }
               
        }
        QCloudCOSXMLService.defaultCOSXML().putObjectCopy(request);
        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    func testCopyObject() {
        // 复制对象时保留对象属性
        self.copyObject();
        // 复制对象时替换对象属性
        self.copyObjectReplaced();
        // .cssg-methods-pragma
    }
}
