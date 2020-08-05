#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketWebsite : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketWebsite

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
 * 设置存储桶静态网站
 */
- (void)putBucketWebsite {
    
    //.cssg-snippet-body-start:[objc-put-bucket-website]
    
    // 存储桶名称，格式为 BucketName-APPID
    NSString *bucket = @"examplebucket-1250000000";
    
    NSString *indexDocumentSuffix = @"index.html";
    NSString *errorDocKey = @"error.html";
    NSString *derPro = @"https";
    int errorCode = 451;
    NSString * replaceKeyPrefixWith = @"404.html";
    QCloudPutBucketWebsiteRequest *putReq = [QCloudPutBucketWebsiteRequest new];
    putReq.bucket = bucket;
    
    QCloudWebsiteConfiguration *config = [QCloudWebsiteConfiguration new];
    
    QCloudWebsiteIndexDocument *indexDocument = [QCloudWebsiteIndexDocument new];
    
    // 指定索引文档的对象键后缀。例如指定为index.html，那么当访问到存储桶的根目录时，会自动返回
    // index.html 的内容，或者当访问到article/目录时，会自动返回 article/index.html的内容
    indexDocument.suffix = indexDocumentSuffix;
    // 索引文档配置
    config.indexDocument = indexDocument;
    
    // 错误文档配置
    QCloudWebisteErrorDocument *errDocument = [QCloudWebisteErrorDocument new];
    errDocument.key = errorDocKey;
    // 指定通用错误文档的对象键，当发生错误且未命中重定向规则中的错误码重定向时，将返回该对象键的内容
    config.errorDocument = errDocument;
    
    // 重定向所有请求配置
    QCloudWebsiteRedirectAllRequestsTo *redir = [QCloudWebsiteRedirectAllRequestsTo new];
    redir.protocol  = derPro;
    // 指定重定向所有请求的目标协议，只能设置为 https
    config.redirectAllRequestsTo = redir;
    
    // 单条重定向规则配置
    QCloudWebsiteRoutingRule *rule = [QCloudWebsiteRoutingRule new];
    
    // 重定向规则的条件配置
    QCloudWebsiteCondition *contition = [QCloudWebsiteCondition new];
    contition.httpErrorCodeReturnedEquals = errorCode;
    rule.condition = contition;
    
    // 重定向规则的具体重定向目标配置
    QCloudWebsiteRedirect *webRe = [QCloudWebsiteRedirect new];
    webRe.protocol = derPro;
    
    // 指定重定向规则的具体重定向目标的对象键，替换方式为替换原始请求中所匹配到的前缀部分，
    // 仅可在 Condition 为 KeyPrefixEquals 时设置
    webRe.replaceKeyPrefixWith = replaceKeyPrefixWith;
    rule.redirect = webRe;
    
    QCloudWebsiteRoutingRules *routingRules = [QCloudWebsiteRoutingRules new];
    routingRules.routingRule = @[rule];
    
    // 重定向规则配置，最多设置100条 RoutingRule
    config.rules = routingRules;
    putReq.websiteConfiguration  = config;
    
    [putReq setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] PutBucketWebsite:putReq];
    
    //.cssg-snippet-body-end
    
}

/**
 * 获取存储桶静态网站
 */
- (void)getBucketWebsite {
    
    //.cssg-snippet-body-start:[objc-get-bucket-website]
    QCloudGetBucketWebsiteRequest *getReq = [QCloudGetBucketWebsiteRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    getReq.bucket = @"examplebucket-1250000000";
    [getReq setFinishBlock:^(QCloudWebsiteConfiguration *  result,
                             NSError * error) {
        
        // 设置重定向规则，最多设置100条RoutingRule
        QCloudWebsiteRoutingRules *rules =result.rules;
        
        // 索引文档
        QCloudWebsiteIndexDocument *indexDocument = result.indexDocument;
        
        // 错误文档
        QCloudWebisteErrorDocument *errorDocument = result.errorDocument;
       
        // 重定向所有请求
        QCloudWebsiteRedirectAllRequestsTo *redirectAllRequestsTo = result.redirectAllRequestsTo;
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketWebsite:getReq];
    
    //.cssg-snippet-body-end

}

/**
 * 删除存储桶静态网站
 */
- (void)deleteBucketWebsite {
    
    //.cssg-snippet-body-start:[objc-delete-bucket-website]
    QCloudDeleteBucketWebsiteRequest *delReq = [QCloudDeleteBucketWebsiteRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    delReq.bucket = @"examplebucket-1250000000";
    
    [delReq setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketWebsite:delReq];
    
    
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testBucketWebsite {
    // 设置存储桶静态网站
    [self putBucketWebsite];
    
    // 获取存储桶静态网站
    [self getBucketWebsite];
    
    // 删除存储桶静态网站
    [self deleteBucketWebsite];
    // .cssg-methods-pragma
    
}

@end
