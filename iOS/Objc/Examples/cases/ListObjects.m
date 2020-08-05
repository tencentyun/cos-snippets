#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface ListObjects : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation ListObjects {
    QCloudListBucketResult* prevPageResult;
}

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
 * 获取首页对象列表
 */
- (void)getBucket {
    
    //.cssg-snippet-body-start:[objc-get-bucket]
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 单次返回的最大条目数量，默认1000
    request.maxKeys = 100;
    
    // 前缀匹配，用来规定返回的文件前缀地址
    request.prefix = @"dir1/";
    
    [request setFinishBlock:^(QCloudListBucketResult * result, NSError* error) {
        // result 返回具体信息
        // QCloudListBucketResult.contents 桶内文件数组
        // QCloudListBucketResult.commonPrefixes 桶内文件夹数组
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    //.cssg-snippet-body-end
    
}

/**
 * 获取第二页对象列表
 */
- (void)getBucketNextPage {
    
    //.cssg-snippet-body-start:[objc-get-bucket-next-page]
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // prevPageResult 是上一页的返回结果
    // 分页参数 默认以UTF-8二进制顺序列出条目，所有列出条目从marker开始
    request.marker = prevPageResult.nextMarker;
    
    // 单次返回的最大条目数量，默认1000
    request.maxKeys = 100;
    
    [request setFinishBlock:^(QCloudListBucketResult * result, NSError* error) {
        // result 返回具体信息
        // QCloudListBucketResult.contents 桶内文件数组
        // QCloudListBucketResult.commonPrefixes 桶内文件夹数组
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    //.cssg-snippet-body-end
}

/**
 * 获取对象列表与子目录
 */
- (void)getBucketWithDelimiter {

    //.cssg-snippet-body-start:[objc-get-bucket-with-delimiter]
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 单次返回的最大条目数量，默认1000
    request.maxKeys = 100;
    
    // 前缀匹配，用来规定返回的文件前缀地址
    request.prefix = @"dir1/";
    
    // 定界符为一个符号，如果有 Prefix，则将 Prefix 到 delimiter 之间的相同路径归为一类，
    // 定义为 Common Prefix，然后列出所有 Common Prefix。如果没有 Prefix，则从路径起点开始
    // delimiter:路径分隔符 固定为 /
    request.delimiter = @"/";
    
    // prevPageResult 是上一页的返回结果
    // 分页参数 默认以UTF-8二进制顺序列出条目，所有列出条目从marker开始
    request.marker = prevPageResult.nextMarker;
    
    [request setFinishBlock:^(QCloudListBucketResult * result, NSError* error) {
        // result 返回具体信息
        // QCloudListBucketResult.contents 桶内文件数组
        // QCloudListBucketResult.commonPrefixes 桶内文件夹数组
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testListObjects {
    // 获取对象列表
    [self getBucket];
    
    // 获取第二页对象列表
    [self getBucketNextPage];
    
    // 获取对象列表与子目录
    [self getBucketWithDelimiter];
    // .cssg-methods-pragma
    
}

@end
