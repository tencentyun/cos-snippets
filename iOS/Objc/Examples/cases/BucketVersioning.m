#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketVersioning : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketVersioning

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

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
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
 * 启用或者暂停存储桶的版本控制功能
 *
 * 1:如果您从未在存储桶上启用过版本控制，则 GET Bucket versioning 请求不返回版本状态值。
 * 2:开启版本控制功能后，只能暂停，不能关闭。
 * 3:设置版本控制状态值为 Enabled 或者 Suspended，表示开启版本控制和暂停版本控制。
 * 4:设置存储桶的版本控制功能，您需要有存储桶的写权限。
 */
- (void)putBucketVersioning {

    //.cssg-snippet-body-start:[objc-put-bucket-versioning]
    // 开启版本控制
    QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket =@"examplebucket-1250000000";
    
    // 说明版本控制的具体信息
    QCloudBucketVersioningConfiguration* versioningConfiguration =
        [[QCloudBucketVersioningConfiguration alloc] init];
    
    request.configuration = versioningConfiguration;
    
    // 说明版本是否开启，枚举值：QCloudCOSBucketVersioningStatusEnabled、
    // QCloudCOSBucketVersioningStatusSuspended
    versioningConfiguration.status = QCloudCOSBucketVersioningStatusEnabled;
    
    [request setFinishBlock:^(id outputObject, NSError* error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
    
    //.cssg-snippet-body-end
}

/**
 *  接口用于实现获得存储桶的版本控制信息
 *
 *  细节分析
 *  1:获取存储桶版本控制的状态，需要有该存储桶的读权限。
 *  2:有三种版本控制状态：未启用版本控制、启用版本控制和暂停版本控制。
 */
- (void)getBucketVersioning {

    //.cssg-snippet-body-start:[objc-get-bucket-versioning]
    QCloudGetBucketVersioningRequest* request =
                                [[QCloudGetBucketVersioningRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    [request setFinishBlock:^(QCloudBucketVersioningConfiguration* result,
                              NSError* error) {
        // 获取多版本状态
        QCloudCOSBucketVersioningStatus * status = result.status;
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucketVersioning:request];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma


- (void)testBucketVersioning {
    // 设置存储桶多版本
    [self putBucketVersioning];
        
    // 获取存储桶多版本状态
    [self getBucketVersioning];
    // .cssg-methods-pragma
        
}

@end
