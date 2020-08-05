#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketDomain : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketDomain

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
 * 设置存储桶源站
 */
- (void)putBucketDomain {
    
    //.cssg-snippet-body-start:[objc-put-bucket-domain]
    
    QCloudPutBucketDomainRequest *req = [QCloudPutBucketDomainRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    req.bucket = @"examplebucket-1250000000";
    
    QCloudDomainConfiguration *config = [QCloudDomainConfiguration new];
    QCloudDomainRule *rule = [QCloudDomainRule new];
    
    // 源站状态，可选 QCloudDomainStatueEnabled、 QCloudDomainStatueDisabled
    rule.status = QCloudDomainStatueEnabled;
    // 域名信息
    rule.name = @"www.baidu.com";
    
    // 替换已存在的配置、有效值CNAME/TXT 填写则强制校验域名所有权之后，再下发配置
    rule.replace = QCloudCOSDomainReplaceTypeTxt;
    rule.type = QCloudCOSDomainTypeRest;
    
    // 规则描述集合的数组
    config.rules = @[rule];
    
    // 域名配置的规则
    req.domain  = config;
    
    [req setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
        
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutBucketDomain:req];
    
    //.cssg-snippet-body-end
    
}

/**
 * 获取存储桶源站
 */
- (void)getBucketDomain {
    
    //.cssg-snippet-body-start:[objc-get-bucket-domain]
    QCloudGetBucketDomainRequest *getReq =  [QCloudGetBucketDomainRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    getReq.bucket = @"examplebucket-1250000000";
    
    [getReq setFinishBlock:^(QCloudDomainConfiguration * _Nonnull result,
                             NSError * _Nonnull error) {
        // 规则描述集合的数组
        NSArray *rules = result.rules;
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetBucketDomain:getReq];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma


- (void)testBucketDomain {
    // 设置存储桶源站
    [self putBucketDomain];
    
    // 获取存储桶源站
    [self getBucketDomain];
    // .cssg-methods-pragma
    
}

@end
