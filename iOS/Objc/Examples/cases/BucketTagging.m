#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketTagging : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketTagging

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
 * 用于为存储桶设置键值对作为存储桶标签，可以协助您管理已有的存储桶资源，并通过标签进行成本管理。
 */
- (void)putBucketTagging {
    
    //.cssg-snippet-body-start:[objc-put-bucket-tagging]
    QCloudPutBucketTaggingRequest *putReq = [QCloudPutBucketTaggingRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    putReq.bucket = @"examplebucket-1250000000";
    
    // 标签集合
    QCloudBucketTagging *taggings = [QCloudBucketTagging new];
    
    QCloudBucketTag *tag1 = [QCloudBucketTag new];
    
    // 标签的 Key，长度不超过128字节, 支持英文字母、数字、空格、加号、减号、下划线、等号、点号、
    // 冒号、斜线
    tag1.key = @"age";
    
    // 标签的 Value，长度不超过256字节, 支持英文字母、数字、空格、加号、减号、下划线、等号、点号
    // 、冒号、斜线
    tag1.value = @"20";
    QCloudBucketTag *tag2 = [QCloudBucketTag new];
    tag2.key = @"name";
    tag2.value = @"karis";
    
    // 标签集合，最多支持10个标签
    QCloudBucketTagSet *tagSet = [QCloudBucketTagSet new];
    tagSet.tag = @[tag1,tag2];
    taggings.tagSet = tagSet;
    
    // 标签集合
    putReq.taggings = taggings;
    
    [putReq setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketTagging:putReq];
    
    //.cssg-snippet-body-end
    
    
}

/**
 * 用于查询指定存储桶下已有的存储桶标签。
 */
- (void)getBucketTagging {
    
    //.cssg-snippet-body-start:[objc-get-bucket-tagging]
    QCloudGetBucketTaggingRequest *getReq = [QCloudGetBucketTaggingRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    getReq.bucket = @"examplebucket-1250000000";
    
    [getReq setFinishBlock:^(QCloudBucketTagging * result, NSError * error) {
        // tag的集合
        QCloudBucketTagSet * tagSet = result.tagSet;
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketTagging:getReq];
    
    //.cssg-snippet-body-end
    
}

/**
 * 用于删除指定存储桶下已有的存储桶标签。
 */
- (void)deleteBucketTagging {
    
    
    //.cssg-snippet-body-start:[objc-delete-bucket-tagging]
    QCloudDeleteBucketTaggingRequest *delReq = [QCloudDeleteBucketTaggingRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    delReq.bucket =  @"examplebucket-1250000000";
    
    [delReq setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketTagging:delReq];
    
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testBucketTagging {
    // 设置存储桶标签
    [self putBucketTagging];
    
    // 获取存储桶标签
    [self getBucketTagging];
    
    // 删除存储桶标签
    [self deleteBucketTagging];
    // .cssg-methods-pragma
    
}

@end
