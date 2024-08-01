#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface ObjectPresignUrl : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation ObjectPresignUrl

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
 * 获取预签名下载链接
 */
- (void)getPresignDownloadUrl {
    
    //.cssg-snippet-body-start:[objc-get-presign-download-url]
     QCloudGetPresignedURLRequest* getPresignedURLRequest = [[QCloudGetPresignedURLRequest alloc] init];
    
    
    // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
    getPresignedURLRequest.bucket = @"examplebucket-1250000000";
    
    
    // 使用预签名 URL 请求的 HTTP 方法。有效值（大小写敏感）为：@"GET"、@"PUT"、@"POST"、@"DELETE"
    getPresignedURLRequest.HTTPMethod = @"GET";
    
    
    // 获取预签名函数，默认签入Header Host；您也可以选择不签入Header Host，但可能导致请求失败或安全漏洞
    getPresignedURLRequest.signHost = YES;
    
    // http 请求参数，传入的请求参数需与实际请求相同，能够防止用户篡改此HTTP请求的参数
    [getPresignedURLRequest setValue:@"value1" forRequestParameter:@"param1"];
    [getPresignedURLRequest setValue:@"value2" forRequestParameter:@"param2"];
    
    // http 请求头部，传入的请求头部需包含在实际请求中，能够防止用户篡改签入此处的HTTP请求头部
    [getPresignedURLRequest setValue:@"value1" forRequestHeader:@"param1"];
    [getPresignedURLRequest setValue:@"value2" forRequestHeader:@"param2"];
    
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
    getPresignedURLRequest.object = @"exampleobject";
    
    
    [getPresignedURLRequest setFinishBlock:^(QCloudGetPresignedURLResult * _Nonnull result,
                                             NSError * _Nonnull error) {
        // 预签名 URL
        NSString* presignedURL = result.presienedURL;
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] getPresignedURL:getPresignedURLRequest];

    //.cssg-snippet-body-end
    
}

/**
 * 获取预签名上传链接
 */
- (void)getPresignUploadUrl {
    
    //.cssg-snippet-body-start:[objc-get-presign-upload-url]
    
    QCloudGetPresignedURLRequest* getPresignedURLRequest = [[QCloudGetPresignedURLRequest alloc] init];
    
    // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
    getPresignedURLRequest.bucket = @"examplebucket-1250000000";
    
    // 使用预签名 URL 请求的 HTTP 方法。有效值（大小写敏感）为：@"GET"、@"PUT"、@"POST"、@"DELETE"
    getPresignedURLRequest.HTTPMethod = @"PUT";
    
    // 获取预签名函数，默认签入Header Host；您也可以选择不签入Header Host，但可能导致请求失败或安全漏洞
    getPresignedURLRequest.signHost = YES;
    
    // http 请求参数，传入的请求参数需与实际请求相同，能够防止用户篡改此HTTP请求的参数
    [getPresignedURLRequest setValue:@"value1" forRequestParameter:@"param1"];
    [getPresignedURLRequest setValue:@"value2" forRequestParameter:@"param2"];
    
    // http 请求头部，传入的请求头部需包含在实际请求中，能够防止用户篡改签入此处的HTTP请求头部
    [getPresignedURLRequest setValue:@"value1" forRequestHeader:@"param1"];
    [getPresignedURLRequest setValue:@"value2" forRequestHeader:@"param2"];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
    getPresignedURLRequest.object = @"exampleobject";
    
    [getPresignedURLRequest setFinishBlock:^(QCloudGetPresignedURLResult * _Nonnull result,
                                             NSError * _Nonnull error) {
          // 预签名 URL
          NSString* presignedURL = result.presienedURL;
    }];
        
    [[QCloudCOSXMLService defaultCOSXML] getPresignedURL:getPresignedURLRequest];

    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testObjectPresignUrl {
    // 获取预签名下载链接
    [self getPresignDownloadUrl];
    
    // 获取预签名上传链接
    [self getPresignUploadUrl];
    // .cssg-methods-pragma
    
}

@end
