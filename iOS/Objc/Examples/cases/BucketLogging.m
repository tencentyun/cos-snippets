#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketLogging : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketLogging

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1250000000";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

    // 脚手架用于获取临时密钥
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue
    requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"]; // 单位是秒
    credential.experationDate = [[[NSDateFormatter alloc] init] dateFromString:@"expiredTime"];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    continueBlock(creator, nil);
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator,
                                               NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

/**
 * 开启存储桶日志服务
 */
- (void)putBucketLogging {

    //.cssg-snippet-body-start:[objc-put-bucket-logging]
    QCloudPutBucketLoggingRequest *request = [QCloudPutBucketLoggingRequest new];
    
    // 说明日志记录配置的状态，如果无子节点信息则意为关闭日志记录
    QCloudBucketLoggingStatus *status = [QCloudBucketLoggingStatus new];

    // 存储桶 logging 设置的具体信息，主要是目标存储桶
    QCloudLoggingEnabled *loggingEnabled = [QCloudLoggingEnabled new];
    
    // 存放日志的目标存储桶，可以是同一个存储桶（但不推荐），或同一账户下、同一地域的存储桶
    loggingEnabled.targetBucket = @"examplebucket-1250000000";
    
    // 日志存放在目标存储桶的指定路径
    loggingEnabled.targetPrefix = @"mylogs";
    
    status.loggingEnabled = loggingEnabled;
    request.bucketLoggingStatus = status;
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    [request setFinishBlock:^(id outputObject, NSError *error) {
       // outputObject 包含所有的响应 http 头部
       NSDictionary* info = (NSDictionary *) outputObject;
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketLogging:request];
    
    //.cssg-snippet-body-end

}

/**
 * 获取存储桶日志服务
 */
- (void)getBucketLogging {

    //.cssg-snippet-body-start:[objc-get-bucket-logging]
    QCloudGetBucketLoggingRequest *getReq = [QCloudGetBucketLoggingRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    getReq.bucket = @"examplebucket-1250000000";
    
    [getReq setFinishBlock:^(QCloudBucketLoggingStatus * _Nonnull result,
                             NSError * _Nonnull error) {
        // 日志配置信息
        QCloudLoggingEnabled *loggingEnabled = result.loggingEnabled;
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucketLogging:getReq];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma


- (void)testBucketLogging {
    // 开启存储桶日志服务
    [self putBucketLogging];
        
    // 获取存储桶日志服务
    [self getBucketLogging];
    // .cssg-methods-pragma
        
}

@end
