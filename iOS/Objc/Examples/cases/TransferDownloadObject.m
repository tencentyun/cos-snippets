#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface TransferDownloadObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation TransferDownloadObject

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1253653367";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
    endpoint.useHTTPS = true;
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
    
    //.cssg-snippet-body-end
}

/**
 * 下载暂停、续传与取消
 */
- (void)transferDownloadObjectInteract {
    //.cssg-snippet-body-start:[objc-transfer-download-object-pause]
    
    //.cssg-snippet-body-end
    
    //.cssg-snippet-body-start:[objc-transfer-download-object-resume]
    
    //.cssg-snippet-body-end
    
    //.cssg-snippet-body-start:[objc-transfer-download-object-cancel]
    
    //.cssg-snippet-body-end
}

/**
 * 批量下载
 */
- (void)transferBatchDownloadObjects {
    //.cssg-snippet-body-start:[objc-transfer-batch-download-objects]
    
    //.cssg-snippet-body-end
}


// .cssg-methods-pragma

- (void)testTransferDownloadObject {
    // 高级接口下载对象
    [self transferDownloadObject];
        
    // 下载暂停、续传与取消
    [self transferDownloadObjectInteract];
        
    // 批量下载
    [self transferBatchDownloadObjects];
        
        
    // .cssg-methods-pragma
}

@end
