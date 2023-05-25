#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudGetVideoRecognitionRequest.h>
#import <QCloudCOSXML/QCloudPostVideoRecognitionRequest.h>
@interface VideoOperation : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation VideoOperation

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1253653367";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

    // 脚手架用于获取临时密钥
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"]; // 单位是秒
    credential.expirationDate = [[[NSDateFormatter alloc] init] dateFromString:@"expiredTime"];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    continueBlock(creator, nil);
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

/**
 * 提交审核任务
 */
- (void)putVideoRecognition{
    //.cssg-snippet-body-start:[objc-put-video-recognition]
    QCloudPostVideoRecognitionRequest * request = [[QCloudPostVideoRecognitionRequest alloc]init];

    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // 截帧模式。Interval 表示间隔模式；Average 表示平均模式；Fps 表示固定帧率模式。
    // Interval 模式：TimeInterval，Count 参数生效。当设置 Count，未设置 TimeInterval 时，表示截取所有帧，共 Count 张图片。
    // Average 模式：Count 参数生效。表示整个视频，按平均间隔截取共 Count 张图片。
    // Fps 模式：TimeInterval 表示每秒截取多少帧，Count 表示共截取多少帧。
    request.mode = QCloudVideoRecognitionModeFps;

    // 视频截帧频率，范围为(0, 60]，单位为秒，支持 float 格式，执行精度精确到毫秒
    request.timeInterval = 1;

    // 视频截帧数量，范围为(0, 10000]。
    request.count = 10;

    // 审核策略，不带审核策略时使用默认策略。具体查看 https://cloud.tencent.com/document/product/460/56345
    request.bizType = @"BizType";

    // 用于指定是否审核视频声音，当值为0时：表示只审核视频画面截图；值为1时：表示同时审核视频画面截图和视频声音。默认值为0。
    request.detectContent = YES;

    request.finishBlock = ^(QCloudPostVideoRecognitionResult * outputObject, NSError *error) {
        // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
        // QCloudPostVideoRecognitionResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] PostVideoRecognition:request];
    //.cssg-snippet-body-end
}

/**
 * 查询视频审核任务
 */
- (void)getVideoRecognitionResult {
    //.cssg-snippet-body-start:[objc-get-video-recognition]
    QCloudGetVideoRecognitionRequest * request = [[QCloudGetVideoRecognitionRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // QCloudPostVideoRecognitionRequest接口返回的jobid
    request.jobId = @"jobid";
    [request setFinishBlock:^(QCloudVideoRecognitionResult * _Nullable result, NSError * _Nullable error) {
        // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
        // QCloudVideoRecognitionResult 类；
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetVideoRecognition:request];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma

- (void)testVideoOperation {
    // 提交审核任务
    [self putVideoRecognition];

    // 查询视频审核任务
    [self getVideoRecognitionResult];
  
    // .cssg-methods-pragma
}

@end
