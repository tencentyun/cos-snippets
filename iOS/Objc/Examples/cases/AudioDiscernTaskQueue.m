#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudGetAudioDiscernTaskQueueRequest.h>
#import <QCloudCOSXML/QCloudUpdateAudioDiscernTaskQueueRequest.h>
#import <QCloudCOSXML/QCloudGetAudioDiscernOpenBucketListRequest.h>

@interface AudioDiscernTaskQueue : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation AudioDiscernTaskQueue

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
 * 查询存储桶是否已开通语音识别功能
 */
-(void)getAudioDiscernOpenBucketList{
    //.cssg-snippet-body-start:[objc-get-audiodiscern-bucketlist]
    QCloudGetAudioDiscernOpenBucketListRequest * request = [[QCloudGetAudioDiscernOpenBucketListRequest alloc]init];

    // 存储桶名称前缀，前缀搜索
    request.bucketName = @"bucketName";

    request.regionName = @"regionName";
    // 地域信息，以“,”分隔字符串，支持 All、ap-shanghai、ap-beijing
    request.regions = @"regions";

    request.finishBlock = ^(QCloudGetAudioOpenBucketListResult * outputObject, NSError *error) {
        // outputObject 详细字段请查看api文档或者SDK源码
        // QCloudGetAudioOpenBucketListResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] GetAudioDiscernOpenBucketList:request];
    //.cssg-snippet-body-end
}


/**
 * 查询语音识别队列
 */
-(void)getAudioDiscernTaskQueue{
    //.cssg-snippet-body-start:[objc-get-audiodiscern-taskqueue]
    QCloudGetAudioDiscernTaskQueueRequest * request = [[QCloudGetAudioDiscernTaskQueueRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    request.regionName = @"regionName";
    // 队列 ID，以“,”符号分割字符串
    request.queueIds = @"1,2,3";

    // 1. Active 表示队列内的作业会被语音识别服务调度执行
    // 2. Paused 表示队列暂停，作业不再会被语音识别服务调度执行，队列内的所有作业状态维持在暂停状态，已经处于识别中的任务将继续执行，不受影响
    request.state = 1;

    [request setFinishBlock:^(QCloudAudioAsrqueueResult * _Nullable result, NSError * _Nullable error) {
            // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
            // QCloudAudioAsrqueueResult 类；
        }];
    [[QCloudCOSXMLService defaultCOSXML] GetAudioDiscernTaskQueue:request];
    //.cssg-snippet-body-end
}

/**
 * 更新语音识别队列
 */
-(void)updateAudioDiscernTaskQueue{
    //.cssg-snippet-body-start:[objc-update-audiodiscern-taskqueue]
    QCloudUpdateAudioDiscernTaskQueueRequest * request = [[QCloudUpdateAudioDiscernTaskQueueRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    request.regionName = @"regionName";
    // 模板名称
    request.name = @"name";
    // 1. Active 表示队列内的作业会被语音识别服务调度执行
    // 2. Paused 表示队列暂停，作业不再会被语音识别服务调度执行，队列内的所有作业状态维持在暂停状态，已经处于识别中的任务将继续执行，不受影响
    request.state = 1;
    // 管道 ID
    request.queueID = @"queueID";

    // 其他更多参数请查看sdk文档或源码注释

    request.finishBlock = ^(QCloudAudioAsrqueueUpdateResult * outputObject, NSError *error) {
        // outputObject 详细字段请查看api文档或者SDK源码
        // QCloudAudioAsrqueueUpdateResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] UpdateAudioDiscernTaskQueue:request];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma
- (void)testAudioOperation {
    
    // 查询存储桶是否已开通语音识别功能
    [self getAudioDiscernOpenBucketList];
    
    // 查询语音识别队列
    [self getAudioDiscernTaskQueue];

    // 更新语音识别队列
    [self updateAudioDiscernTaskQueue];
  
    // .cssg-methods-pragma
}

@end
