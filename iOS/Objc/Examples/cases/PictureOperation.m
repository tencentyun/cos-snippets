#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface PictureOperation : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation PictureOperation

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
 * 上传时图片处理
 */
- (void)uploadWithPicOperation {
    //.cssg-snippet-body-start:[objc-upload-with-pic-operation]
    
    //.cssg-snippet-body-end
}

/**
 * 对云上数据进行图片处理
 */
- (void)processWithPicOperation {
    //.cssg-snippet-body-start:[objc-process-with-pic-operation]
    
    //.cssg-snippet-body-end
}

/**
 * 上传时添加盲水印
 */
- (void)putObjectWithWatermark {
    //.cssg-snippet-body-start:[objc-put-object-with-watermark]
    
    //.cssg-snippet-body-end
}

/**
 * 下载时添加盲水印
 */
- (void)downloadObjectWithWatermark {
    //.cssg-snippet-body-start:[objc-download-object-with-watermark]
    
    //.cssg-snippet-body-end
}

/**
 * 图片审核
 */
- (void)sensitiveContentRecognition {
    //.cssg-snippet-body-start:[objc-sensitive-content-recognition]
    
    //.cssg-snippet-body-end
}


// .cssg-methods-pragma

- (void)testPictureOperation {
    // 上传时图片处理
    [self uploadWithPicOperation];

    // 对云上数据进行图片处理
    [self processWithPicOperation];
        
    // 上传时添加盲水印
    [self putObjectWithWatermark];
        
    // 下载时添加盲水印
    [self downloadObjectWithWatermark];
        
    // 图片审核
    [self sensitiveContentRecognition];
        
        
    // .cssg-methods-pragma
}

@end