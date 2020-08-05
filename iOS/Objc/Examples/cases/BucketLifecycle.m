#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketLifecycle : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketLifecycle

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
 * 设置存储桶生命周期
 */
- (void)putBucketLifecycle {
    
    //.cssg-snippet-body-start:[objc-put-bucket-lifecycle]
    QCloudPutBucketLifecycleRequest* request = [QCloudPutBucketLifecycleRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    __block QCloudLifecycleConfiguration* lifecycleConfiguration =
    [[QCloudLifecycleConfiguration alloc] init];
    
    // 规则描述
    QCloudLifecycleRule* rule = [[QCloudLifecycleRule alloc] init];
    
    // 用于唯一地标识规则
    rule.identifier = @"identifier";
    
    // 指明规则是否启用，枚举值：Enabled，Disabled
    rule.status = QCloudLifecycleStatueEnabled;
    
    // Filter 用于描述规则影响的 Object 集合
    QCloudLifecycleRuleFilter* filter = [[QCloudLifecycleRuleFilter alloc] init];
    
    // 指定规则所适用的前缀。匹配前缀的对象受该规则影响，Prefix 最多只能有一个
    filter.prefix = @"prefix1";
    
    // Filter 用于描述规则影响的 Object 集合
    rule.filter = filter;
    
    // 规则转换属性，对象何时转换为 Standard_IA 或 Archive
    QCloudLifecycleTransition* transition = [[QCloudLifecycleTransition alloc] init];
    
    // 指明规则对应的动作在对象最后的修改日期过后多少天操作：
    transition.days = 100;
    
    // 指定 Object 转储到的目标存储类型，枚举值： STANDARD_IA，ARCHIVE
    transition.storageClass = QCloudCOSStorageStandardIA;
    rule.transition = transition;
    request.lifeCycle = lifecycleConfiguration;
    
    // 生命周期配置
    request.lifeCycle.rules = @[rule];
    [request setFinishBlock:^(id outputObject, NSError* error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucketLifecycle:request];
    
    //.cssg-snippet-body-end

}

/**
 * 获取存储桶生命周期
 */
- (void)getBucketLifecycle {
    
    //.cssg-snippet-body-start:[objc-get-bucket-lifecycle]
    QCloudGetBucketLifecycleRequest* request = [QCloudGetBucketLifecycleRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    [request setFinishBlock:^(QCloudLifecycleConfiguration* result,NSError* error) {
        // 可以从 result 中获取返回信息
        // result.rules 规则描述集合的数组
     
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketLifecycle:request];
    
    //.cssg-snippet-body-end
    
}

/**
 * 删除存储桶生命周期
 */
- (void)deleteBucketLifecycle {
    
    //.cssg-snippet-body-start:[objc-delete-bucket-lifecycle]
    QCloudDeleteBucketLifeCycleRequest* request =
    [[QCloudDeleteBucketLifeCycleRequest alloc ] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    [request setFinishBlock:^(QCloudLifecycleConfiguration* deleteResult, NSError* error) {
        // 返回删除结果
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketLifeCycle:request];
    
    //.cssg-snippet-body-end
}
// .cssg-methods-pragma


- (void)testBucketLifecycle {
    // 设置存储桶生命周期
    [self putBucketLifecycle];
    
    // 获取存储桶生命周期
    [self getBucketLifecycle];
    
    // 删除存储桶生命周期
    [self deleteBucketLifecycle];
    // .cssg-methods-pragma
    
}

@end
