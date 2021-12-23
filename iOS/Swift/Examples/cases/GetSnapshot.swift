import XCTest
import QCloudCOSXML

class GetSnapshot: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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


    // 用于查询已经开通媒体处理功能的存储桶
    func getDescribeMediaBuckets() {
        //.cssg-snippet-body-start:[swift-media-buckets]
        let request : QCloudGetDescribeMediaBucketsRequest = QCloudGetDescribeMediaBucketsRequest();
        // 地域信息，例如 ap-shanghai、ap-beijing，若查询多个地域以“,”分隔字符串，支持中国大陆地域
        request.regions = ["ap-shanghai"];
        // 存储桶名称，以“,”分隔，支持多个存储桶，精确搜索
        request.bucketNames = ["bucketNames"];
        // 存储桶名称前缀，前缀搜索
        request.bucketName = "bucketName";
        // 第几页
        request.pageNumber = 0;
        // 每页个数
        request.pageSize = 100;
                
        request.finishBlock = { (result, error) in
            // result 请求到的媒体信息，详细字段请查看api文档或者SDK源码
            // QCloudMediaInfo 类；
        }
        QCloudCOSXMLService.defaultCOSXML().ciGetDescribeMediaBuckets(request);
        //.cssg-snippet-body-end
    }
    
    // 获取截图
    func getSnapshot() {
        //.cssg-snippet-body-start:[swift-get-snapshot]
        let request : QCloudGetGenerateSnapshotRequest = QCloudGetGenerateSnapshotRequest();
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "test.mp4";
        // 存储桶名称，以“,”分隔，支持多个存储桶，精确搜索
        request.bucket = "CURRENT_BUCKET";
        // 截图配置信息
        request.generateSnapshotConfiguration = QCloudGenerateSnapshotConfiguration();
        // 截取哪个时间点的内容，单位为秒 必传
        request.generateSnapshotConfiguration.time = 10;
        // 截图的宽。默认为0
        request.generateSnapshotConfiguration.width = 100;
        // 截图的宽。默认为0
        request.generateSnapshotConfiguration.height = 100;

        // 截帧方式:枚举值
        //  GenerateSnapshotModeExactframe：截取指定时间点的帧
        //  GenerateSnapshotModeKeyframe：截取指定时间点之前的最近的
        //  默认值为 exactframe
        request.generateSnapshotConfiguration.mode = QCloudGenerateSnapshotMode.exactframe;

        // 图片旋转方式:枚举值
        // GenerateSnapshotRotateTypeAuto：按视频旋转信息进行自动旋转
        // GenerateSnapshotRotateTypeOff：不旋转
        // 默认值为 auto
        request.generateSnapshotConfiguration.rotate = QCloudGenerateSnapshotRotateType.auto;

        // 截图的格式:枚举值
        // GenerateSnapshotFormatJPG：jpg
        // GenerateSnapshotFormatPNG：png
        // 默认 jpg
        request.generateSnapshotConfiguration.format = QCloudGenerateSnapshotFormat.JPG;
                
        request.finishBlock = { (result, error) in
            // result 截图信息，详细字段请查看api文档或者SDK源码
            // QCloudGenerateSnapshotResult  类；
        }
        QCloudCOSXMLService.defaultCOSXML().getGenerateSnapshot(request);
        //.cssg-snippet-body-end
    }
    
    // 用于查询媒体文件的信息
    func getMediaInfo() {
        //.cssg-snippet-body-start:[swift-get-media-info]
        let request : QCloudGetMediaInfoRequest = QCloudGetMediaInfoRequest();
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";
                
        request.finishBlock = { (result, error) in
            // outputObject 请求到的媒体信息，详细字段请查看api文档或者SDK源码
            // QCloudMediaInfo 类；
        }
        QCloudCOSXMLService.defaultCOSXML().ciGetMediaInfo(request);
        //.cssg-snippet-body-end
    }

    // .cssg-methods-pragma

    func testGetSnapshot() {
        // .cssg-methods-pragma
        // 用于查询已经开通媒体处理功能的存储桶
        self.getDescribeMediaBuckets();
        
        // 获取截图
        self.getSnapshot();
    
        // 用于查询媒体文件的信息。
        self.getMediaInfo();
    }
}
