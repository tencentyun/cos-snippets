#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface TransferObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation TransferObject

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
 * 高级接口上传对象
 */
- (void)transferUploadFile {
    
    //.cssg-snippet-body-start:[objc-transfer-upload-file]
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    // 本地文件路径
    NSURL* url = [NSURL fileURLWithPath:@"文件的URL"];
    
    // 存储桶名称，格式为 BucketName-APPID
    put.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = @"exampleobject";
    
    // 需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
    put.body =  url;
    // 监听上传进度
    [put setSendProcessBlock:^(int64_t bytesSent,
                               int64_t totalBytesSent,
                               int64_t totalBytesExpectedToSend) {
        // bytesSent                   新增字节数
        // totalBytesSent              本次上传的总字节数
        // totalBytesExpectedToSend    本地上传的目标字节数
    }];
    
    // 监听上传结果
    [put setFinishBlock:^(id outputObject, NSError *error) {
        // 可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
        NSDictionary * result = (NSDictionary *)outputObject;
    }];
    
    [put setInitMultipleUploadFinishBlock:^(QCloudInitiateMultipartUploadResult *
                                            multipleUploadInitResult,
                                            QCloudCOSXMLUploadObjectResumeData resumeData) {
        // 在初始化分块上传完成以后会回调该 block，在这里可以获取 resumeData，uploadid
        NSString* uploadId = multipleUploadInitResult.uploadId;
    }];
    
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    
    // 如果需要中途取消上传，调用 cancel 方法
    [put abort:^(id outputObject, NSError *error) {

    }];
    //.cssg-snippet-body-end
}

/**
 * 高级接口上传二进制数据
 */
- (void)transferUploadBytes {
    //.cssg-snippet-body-start:[objc-transfer-upload-bytes]
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    put.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = @"exampleobject";
    
    // 需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
    put.body = [@"My Example Content" dataUsingEncoding:NSUTF8StringEncoding];
    
    // 监听上传进度
    [put setSendProcessBlock:^(int64_t bytesSent,
                               int64_t totalBytesSent,
                               int64_t totalBytesExpectedToSend) {
        // bytesSent                   新增字节数
        // totalBytesSent              本次上传的总字节数
        // totalBytesExpectedToSend    本地上传的目标字节数
    }];
    
    // 监听上传结果
    [put setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    
    //.cssg-snippet-body-end
}

/**
 * 高级接口流式上传
 */
- (void)transferUploadStream {
    
    
    //.cssg-snippet-body-start:[objc-transfer-upload-stream]
    //.cssg-snippet-body-end
    
}

/**
 * 高级接口下载对象
 */
- (void)transferDownloadObject {
    
    //.cssg-snippet-body-start:[objc-transfer-download-object]
    QCloudCOSXMLDownloadObjectRequest * request = [QCloudCOSXMLDownloadObjectRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    
    // 设置下载的路径 URL，如果设置了，文件将会被下载到指定路径中
    request.downloadingURL = [NSURL fileURLWithPath:@"Local File Path"];
    
    // 本地已下载的文件大小，如果是从头开始下载，请不要设置
    request.localCacheDownloadOffset = 100;
    
    // 监听下载结果
    [request setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    
    // 监听下载进度
    [request setDownProcessBlock:^(int64_t bytesDownload,
                                   int64_t totalBytesDownload,
                                   int64_t totalBytesExpectedToDownload) {
        
        // bytesDownload                   新增字节数
        // totalBytesDownload              本次下载接收的总字节数
        // totalBytesExpectedToDownload    本次下载的目标字节数
    }];
    
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] DownloadObject:request];
    
    // 取消下载
    // 如果需要取消下载，调用cancel方法
    [request cancel];
    
    //.cssg-snippet-body-end
}

/**
 * 高级接口拷贝对象
 */
- (void)transferCopyObject {
    
    //.cssg-snippet-body-start:[objc-transfer-copy-object]
    QCloudCOSXMLCopyObjectRequest* request = [[QCloudCOSXMLCopyObjectRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    
    // 文件来源存储桶，需要是公有读或者在当前账号有权限
    request.sourceBucket = @"sourcebucket-1250000000";
    
    // 源文件名称
    request.sourceObject = @"sourceObject";
    
    // 源文件的 APPID
    request.sourceAPPID = @"1250000000";
    
    // 来源的地域
    request.sourceRegion= @"COS_REGION";
    
    [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
        // 可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
    }];
    
    // 注意如果是跨地域复制，这里使用的 transferManager 所在的 region 必须为目标桶所在的 region
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] CopyObject:request];
    
    // 取消copy
    // 若需要取消copy 调用cancel方法
    [request cancel];
    
    //.cssg-snippet-body-end
    
}

/**
 * 批量上传任务
 */
- (void)batchUploadObjects {
    
    //.cssg-snippet-body-start:[objc-batch-upload-objects]
    
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testTransferObject {
    // 高级接口上传对象
    [self transferUploadFile];
    
    // 高级接口上传二进制数据
    [self transferUploadBytes];
    
    // 高级接口流式上传
    [self transferUploadStream];
    
    // 高级接口下载对象
    [self transferDownloadObject];
    
    // 高级接口拷贝对象
    [self transferCopyObject];
    
    // 批量上传任务
    [self batchUploadObjects];
    // .cssg-methods-pragma
    
}

@end
