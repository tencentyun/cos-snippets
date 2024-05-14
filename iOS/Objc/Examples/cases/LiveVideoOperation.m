#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudPostLiveVideoRecognitionRequest.h>
#import <QCloudCOSXML/QCloudGetLiveVideoRecognitionRequest.h>
#import <QCloudCOSXML/QCloudCancelLiveVideoRecognitionRequest.h>
@interface LiveVideoOperation : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation LiveVideoOperation

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
- (void)putLiveVideoRecognition{
    //.cssg-snippet-body-start:[objc-put-video-recognition]
    QCloudPostLiveVideoRecognitionRequest * request = [[QCloudPostLiveVideoRecognitionRequest alloc]init];

    request.regionName = @"regionName";

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // 表示直播流所要转存的路径，直播流的 ts 文件和 m3u8 文件将保存在本桶该目录下。m3u8 文件保存文件名为 Path/{$JobId}.m3u8，ts 文件的保存文件名为 Path/{$JobId}-{$Realtime}.ts，其中 Realtime 为17位年月日时分秒毫秒时间。
    request.path = @"test";

    // 需要审核的直播流播放地址，例如 rtmp://example.com/live/123。
    request.url = @"test";

    request.finishBlock = ^(QCloudPostVideoRecognitionResult * outputObject, NSError *error) {
     // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
     // QCloudPostVideoRecognitionResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] PostLiveVideoRecognition:request];
    //.cssg-snippet-body-end
}

/**
 * 查询直播审核任务
 */
- (void)getVideoRecognitionResult {
    //.cssg-snippet-body-start:[objc-get-video-recognition]
    QCloudGetLiveVideoRecognitionRequest * request = [[QCloudGetLiveVideoRecognitionRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // QCloudPostLiveVideoRecognitionRequest接口返回的jobid
    request.jobId = @"jobid";

    request.regionName = @"regionName";

    [request setFinishBlock:^(QCloudVideoRecognitionResult * _Nullable result, NSError * _Nullable error) {
            // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudVideoRecognitionResult 类；
        }];
    [[QCloudCOSXMLService defaultCOSXML] GetLiveVideoRecognition:request];
    //.cssg-snippet-body-end
}


/**
 取消视频审核任务
 */
-(void)cancelLiveVideoRecognition{
    QCloudCancelLiveVideoRecognitionRequest * request = [[QCloudCancelLiveVideoRecognitionRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // QCloudPostLiveVideoRecognitionRequest接口返回的jobid
    request.jobId = @"jobid";

    request.regionName = @"regionName";

    request.finishBlock = ^(QCloudPostVideoRecognitionResult * outputObject, NSError *error) {
    // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
    // QCloudPostVideoRecognitionResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] CancelLiveVideoRecognition:request];
}

// .cssg-methods-pragma
- (void)testLiveVideoOperation {
    // 提交审核任务
    [self putLiveVideoRecognition];

    // 查询直播审核任务
    [self getVideoRecognitionResult];
    
    // 取消直播审核任务
    [self cancelLiveVideoRecognition];
  
    // .cssg-methods-pragma
}

@end
