#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketReplication : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketReplication

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
    // 在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    // 强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 单位是秒
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"];
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
 * 用于向已启用版本控制的存储桶中配置跨地域复制规则。如果存储桶已经配置了跨地域复制规则，那么该请
 * 求会替换现有配置。
 */
- (void)putBucketReplication {
    
    //.cssg-snippet-body-start:[objc-put-bucket-replication]
    QCloudPutBucketReplicationRequest* request = [[QCloudPutBucketReplicationRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 说明所有跨地域配置信息
    QCloudBucketReplicationConfiguation* replConfiguration =
                                [[QCloudBucketReplicationConfiguation alloc] init];
    
    // 发起者身份标示
    replConfiguration.role = @"qcs::cam::uin/100000000001:uin/100000000001";
    
    // 具体配置信息
    QCloudBucketReplicationRule* rule = [[QCloudBucketReplicationRule alloc] init];
    
    // 用来标注具体 Rule 的名称
    rule.identifier = @"identifier";
    rule.status = QCloudCOSXMLStatusEnabled;
    
    // 资源标识符
    QCloudBucketReplicationDestination* destination = [[QCloudBucketReplicationDestination alloc] init];
    NSString* destinationBucket = @"destinationbucket-1250000000";
    
    // 目标存储桶所在地域
    NSString* region = @"ap-beijing";
    destination.bucket = [NSString stringWithFormat:@"qcs::cos:%@::%@",region,destinationBucket];
    
    // 目标存储桶信息
    rule.destination = destination;
    
    // 前缀匹配策略，不可重叠，重叠返回错误。前缀匹配根目录为空
    rule.prefix = @"prefix1";
    replConfiguration.rule = @[rule];
    request.configuation = replConfiguration;
    
    [request setFinishBlock:^(id outputObject, NSError* error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketRelication:request];
    
    //.cssg-snippet-body-end

}

/**
 * 接口用于查询存储桶中用户跨地域复制配置信息。用户发起该请求时需获得请求签名，表明该请求已获得许可。
 */
- (void)getBucketReplication {

    //.cssg-snippet-body-start:[objc-get-bucket-replication]
    QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    [request setFinishBlock:^(QCloudBucketReplicationConfiguation* result,
                              NSError* error) {
        // 具体配置信息，最多支持 1000 个，所有策略只能指向一个目标存储桶
        NSArray *rules = result.rule;
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
    
    //.cssg-snippet-body-end

}

/**
 * 用来删除存储桶中的跨地域复制配置。用户发起该请求时需获得请求签名，表明该请求已获得许可。
 */
- (void)deleteBucketReplication {

    //.cssg-snippet-body-start:[objc-delete-bucket-replication]
    QCloudDeleteBucketReplicationRequest* request =
                            [[QCloudDeleteBucketReplicationRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    [request setFinishBlock:^(id outputObject, NSError* error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketReplication:request];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma


- (void)testBucketReplication {
    // 设置存储桶跨地域复制规则
    [self putBucketReplication];
        
    // 获取存储桶跨地域复制规则
    [self getBucketReplication];
        
    // 删除存储桶跨地域复制规则
    [self deleteBucketReplication];
    // .cssg-methods-pragma
        
}

@end
