#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudPostAudioDiscernTaskRequest.h>
#import <QCloudCOSXML/QCloudBatchGetAudioDiscernTaskRequest.h>
#import <QCloudCOSXML/QCloudGetAudioDiscernTaskRequest.h>
#import <QCloudCOSXML/QCloudPostAudioDiscernTaskInfo.h>
@interface AudioDiscernTask : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation AudioDiscernTask

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
 * 提交一个语音识别任务
 */
- (void)postAudioDiscernTask{
    //.cssg-snippet-body-start:[objc-post-audiodiscern]
    
    QCloudPostAudioDiscernTaskRequest * request = [[QCloudPostAudioDiscernTaskRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"BucketName-APPID";
    request.regionName = @"regionName";

    QCloudPostAudioDiscernTaskInfo* taskInfo = [QCloudPostAudioDiscernTaskInfo new];
    taskInfo.Tag = @"SpeechRecognition";
    // 队列 ID ,通过查询语音识别队列获取
    taskInfo.QueueId = @"QueueId";
    // 操作规则
    QCloudPostAudioDiscernTaskInfoInput * input = QCloudPostAudioDiscernTaskInfoInput.new;
    input.Object = @"test1";
    // 待操作的语音文件
    taskInfo.Input = input;
    QCloudPostAudioDiscernOperation * op = [QCloudPostAudioDiscernOperation new];
    QCloudPostAudioDiscernTaskInfoOutput * output = QCloudPostAudioDiscernTaskInfoOutput.new;
    output.Region = @"regionName";
    output.Bucket = @"BucketName-APPID";
    output.Object = @"test";
    // 结果输出地址
    op.Output = output;

    QCloudPostAudioDiscernRecognition * speechRecognition = [QCloudPostAudioDiscernRecognition new];
    speechRecognition.EngineModelType =@"16k_zh";
    speechRecognition.ChannelNum = 1;
    speechRecognition.ResTextFormat = 0;
    speechRecognition.ConvertNumMode = 0;
    // 当 Tag 为 SpeechRecognition 时有效，指定该任务的参数
    op.SpeechRecognition = speechRecognition;
    // 操作规则
    taskInfo.Operation = op;
    //  语音识别任务
    request.taskInfo = taskInfo;

    [request setFinishBlock:^(QCloudPostAudioDiscernTaskResult * _Nullable result, NSError * _Nullable error) {
        // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
        // QCloudPostAudioRecognitionResult 类；
    }];
    [[QCloudCOSXMLService defaultCOSXML] PostAudioDiscernTask:request];
    //.cssg-snippet-body-end
}

/**
 * 查询指定的语音识别任务
 */
- (void)getAudioDiscernTask {
    //.cssg-snippet-body-start:[objc-get-audiodiscern-task]
    QCloudGetAudioDiscernTaskRequest * request = [[QCloudGetAudioDiscernTaskRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // QCloudPostAudioDiscernTaskRequest接口返回的jobid
    request.jobId = @"jobid";

    request.regionName = @"regionName";

    request.finishBlock = ^(QCloudGetAudioDiscernTaskResult * outputObject, NSError *error) {
        // outputObject 详细字段请查看api文档或者SDK源码
        // QCloudGetAudioDiscernTaskResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] GetAudioDiscernTask:request];
    //.cssg-snippet-body-end
}

/**
 * 批量拉取语音识别任务
 */
-(void)batchGetAudioDiscernTask{
    //.cssg-snippet-body-start:[objc-batch-audiodiscern-task]
    QCloudBatchGetAudioDiscernTaskRequest * request = [[QCloudBatchGetAudioDiscernTaskRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // 拉取该队列 ID 下的任务。
    // 通过查询语音识别队列获取
    request.queueId = @"queueId";

    request.regionName = @"regionName";

    request.states = QCloudTaskStatesSuccess | QCloudTaskStatesCancel;

    // 其他更多参数请查阅sdk文档或源码注释

    request.finishBlock = ^(QCloudBatchGetAudioDiscernTaskResult * outputObject, NSError *error) {
        // outputObject 任务结果，详细字段请查看api文档或者SDK源码
        // QCloudBatchGetAudioDiscernTaskResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] BatchGetAudioDiscernTask:request];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma
- (void)testAudioOperation {
    // 提交一个语音识别任务
    [self postAudioDiscernTask];

    // 查询指定的语音识别任务
    [self getAudioDiscernTask];
    
    // 批量拉取语音识别任务
    [self batchGetAudioDiscernTask];
  
    // .cssg-methods-pragma
}

@end
