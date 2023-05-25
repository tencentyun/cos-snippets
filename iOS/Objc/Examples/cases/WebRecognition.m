#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudPostWebRecognitionRequest.h>
#import <QCloudCOSXML/QCloudGetWebRecognitionRequest.h>

@interface WebRecognition : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation WebRecognition

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
- (void)putWebRecognition{
    //.cssg-snippet-body-start:[objc-post-web-recognition]
    
    QCloudPostWebRecognitionRequest * request = [[QCloudPostWebRecognitionRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // 文件所在地域
    request.regionName = @"regionName";

    request.url = @"www.****.com";

    request.finishBlock = ^(QCloudPostWebRecognitionResult * outputObject, NSError *error) {
        // outputObject 提交审核反馈信息 包含用于查询的job id，详细字段请查看api文档或者SDK源码
        // QCloudPostTextRecognitionResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] PostWebRecognition:request];
   
    //.cssg-snippet-body-end
}

/**
 * 查询审核任务
 */
- (void)getWebRecognitionResult {
    //.cssg-snippet-body-start:[objc-get-web-recognition]
    QCloudGetWebRecognitionRequest * request = [[QCloudGetWebRecognitionRequest alloc]init];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // 文件所在地域
    request.regionName = @"regionName";

    // QCloudPostWebRecognitionRequest接口返回的jobid
    request.jobId = @"jobid";

    request.finishBlock = ^(QCloudWebRecognitionResult * outputObject, NSError *error) {
        // outputObject 审核结果 包含用于查询的job id，详细字段请查看api文档或者SDK源码
        // QCloudWebRecognitionResult 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] GetWebRecognition:request];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma

- (void)testWebOperation {
    // 提交审核任务
    [self putWebRecognition];

    // 查询审核任务
    [self getWebRecognitionResult];
  
    // .cssg-methods-pragma
}

@end
