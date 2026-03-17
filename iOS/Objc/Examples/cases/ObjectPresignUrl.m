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
        [self downloadFile:presignedURL retryCount:0];
        
    }];
    
    
    [[QCloudCOSXMLService defaultCOSXML] getPresignedURL:getPresignedURLRequest];

    //.cssg-snippet-body-end
    
}

-(void)downloadFile:(NSString *)presignedURL retryCount:(NSInteger)retryCount{
    // 使用预签名链接进行下载文件
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:presignedURL]];
    // 指定HTTPMethod为GET
    request.HTTPMethod = @"GET";
    [[[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        // 具体错误码请查看 https://cloud.tencent.com/document/product/436/7730#.E9.94.99.E8.AF.AF.E7.A0.81.E5.88.97.E8.A1.A8
        NSInteger statusCode = 0;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        }

        if (error && [self isNetworkErrorAndRecoverable:error] && retryCount == 0) {
            // 网络可恢复错误，进行重试
            [self downloadFile:presignedURL retryCount:retryCount + 1];
        } else if (!error && statusCode >= 500 && retryCount == 0) {
            // 服务端 5xx 错误，进行重试
            [self downloadFile:presignedURL retryCount:retryCount + 1];
        } else if (error) {
            // 文件下载失败，执行失败的业务逻辑
            NSLog(@"文件下载失败：%@", error);
        } else if (statusCode >= 200 && statusCode < 300) {
            // location 下载成功后的本地文件路径
            NSLog(@"文件下载成功，本地路径：%@", location.path);
        } else {
            // 4xx 等其他错误
            // 下载任务的错误信息在 location 对应的临时文件中，需要读取解析
            NSData *errorData = [NSData dataWithContentsOfURL:location];
            NSString *errorBody = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            NSLog(@"文件下载失败，状态码：%ld，响应体：%@", (long)statusCode, errorBody);
        }
    }] resume];
}


- (BOOL)isNetworkErrorAndRecoverable:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorCancelled:
            case NSURLErrorBadURL:
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorSecureConnectionFailed:
            case NSURLErrorServerCertificateHasBadDate:
            case NSURLErrorServerCertificateUntrusted:
            case NSURLErrorServerCertificateHasUnknownRoot:
            case NSURLErrorServerCertificateNotYetValid:
            case NSURLErrorClientCertificateRejected:
            case NSURLErrorClientCertificateRequired:
            case NSURLErrorCannotLoadFromNetwork:
                return NO;
            case NSURLErrorCannotConnectToHost:
            default:
                return YES;
        }
    }
    if (error.userInfo && error.userInfo[@"Code"]) {
        NSString *serverCode = error.userInfo[@"Code"];
        if ([serverCode isEqualToString:@"InvalidDigest"] || [serverCode isEqualToString:@"BadDigest"] ||
            [serverCode isEqualToString:@"InvalidSHA1Digest"] || [serverCode isEqualToString:@"RequestTimeOut"]) {
            return YES;
        }
    }
    return NO;
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
           [self uploadFile:presignedURL retryCount:0];
    }];
        
    [[QCloudCOSXMLService defaultCOSXML] getPresignedURL:getPresignedURLRequest];

    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma
-(void)uploadFile:(NSString *)presignedURL retryCount:(NSInteger)retryCount{
    // 使用预签名链接进行上传文件
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:presignedURL]];
    // 指定HTTPMethod 为PUT
    request.HTTPMethod = @"PUT";

    // 方式一：从文件路径上传（推荐，更贴近真实场景）
    // NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/your/file"];
    // NSData *fileData = [NSData dataWithContentsOfURL:fileURL];

    // 方式二：从 NSData 上传（此处使用测试数据演示）
    NSData *fileData = [@"testtest" dataUsingEncoding:NSUTF8StringEncoding];

    [[[NSURLSession sharedSession]
      uploadTaskWithRequest:request fromData:fileData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 具体错误码请查看 https://cloud.tencent.com/document/product/436/7730#.E9.94.99.E8.AF.AF.E7.A0.81.E5.88.97.E8.A1.A8
        NSInteger statusCode = 0;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        }

        if (error && [self isNetworkErrorAndRecoverable:error] && retryCount == 0) {
            // 网络可恢复错误，进行重试
            [self uploadFile:presignedURL retryCount:retryCount + 1];
        } else if (!error && statusCode >= 500 && retryCount == 0) {
            // 服务端 5xx 错误，进行重试
            [self uploadFile:presignedURL retryCount:retryCount + 1];
        } else if (error) {
            // 文件上传失败，执行失败的业务逻辑
            NSLog(@"文件上传失败：%@", error);
        } else if (statusCode >= 200 && statusCode < 300) {
            // 文件上传成功，执行成功的业务逻辑
            NSLog(@"文件上传成功");
        } else {
            // 4xx 等其他错误，解析响应体中的错误信息
            NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"文件上传失败，状态码：%ld，响应体：%@", (long)statusCode, responseBody);
        }
    }] resume];

}

- (void)testObjectPresignUrl {
    // 获取预签名下载链接
    [self getPresignDownloadUrl];
    
    // 获取预签名上传链接
    [self getPresignUploadUrl];
    // .cssg-methods-pragma
    
}

@end
