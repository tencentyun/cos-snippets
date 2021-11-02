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

    // 提交审核任务
    func putVideoRecognition() {
        //.cssg-snippet-body-start:[swift-upload-with-pic-operation]
        
        let request : QCloudPostVideoRecognitionRequest = QCloudPostVideoRecognitionRequest();

        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // 审核类型，拥有 porn（涉黄识别）、terrorist（涉暴恐识别）、politics（涉政识别）、ads（广告识别）四种，
        // 用户可选择多种识别类型，例如 detect-type=porn,ads 表示对图片进行涉黄及广告审核
        // 可以使用或进行组合赋值 如： QCloudRecognitionPorn | QCloudRecognitionTerrorist
        reqeust.detectType = QCloudRecognitionPorn | QCloudRecognitionAds | QCloudRecognitionPolitics | QCloudRecognitionTerrorist;

        // 截帧模式。Interval 表示间隔模式；Average 表示平均模式；Fps 表示固定帧率模式。
        // Interval 模式：TimeInterval，Count 参数生效。当设置 Count，未设置 TimeInterval 时，表示截取所有帧，共 Count 张图片。
        // Average 模式：Count 参数生效。表示整个视频，按平均间隔截取共 Count 张图片。
        // Fps 模式：TimeInterval 表示每秒截取多少帧，Count 表示共截取多少帧。
        reqeust.mode = QCloudVideoRecognitionModeFps;

        // 视频截帧频率，范围为(0, 60]，单位为秒，支持 float 格式，执行精度精确到毫秒
        reqeust.timeInterval = 1;

        // 视频截帧数量，范围为(0, 10000]。
        reqeust.count = 10;

        // 审核策略，不带审核策略时使用默认策略。具体查看 https://cloud.tencent.com/document/product/460/56345
        request.bizType = BizType;

        // 用于指定是否审核视频声音，当值为0时：表示只审核视频画面截图；值为1时：表示同时审核视频画面截图和视频声音。默认值为0。
        reqeust.detectContent = YES;
                
        request.finishBlock = { (result, error) in
             // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudPostVideoRecognitionResult 类；
        }
        QCloudCOSXMLService.defaultCOSXML().PostVideoRecognition(request);
        
        //.cssg-snippet-body-end
    }

    // 查询视频审核任务
    func getVideoRecognitionResult() {
        //.cssg-snippet-body-start:[swift-process-with-pic-operation]
        let request : QCloudGetVideoRecognitionRequest = QCloudGetVideoRecognitionRequest();

        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";

        // QCloudPostVideoRecognitionRequest接口返回的jobid
        reqeust.jobId = "jobid";
                
        request.finishBlock = { (result, error) in
            // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudVideoRecognitionResult 类；
        }
        QCloudCOSXMLService.defaultCOSXML().GetVideoRecognition(request);
        //.cssg-snippet-body-end
    }
    
    // .cssg-methods-pragma

    func testPictureOperation() {
        // 提交审核任务
        self.putVideoRecognition();

        // 查询视频审核任务
        self.getVideoRecognitionResult();
    
        // .cssg-methods-pragma
    }
}
