#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface QrcodeRecognition : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation QrcodeRecognition

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
 * 上传时进行二维码识别
 */
- (void)uploadWithQRcodeRecognition {
    //.cssg-snippet-body-start:[objc-upload-with-QRcode-recognition]
    QCloudCIPutObjectQRCodeRecognitionRequest *req = [QCloudCIPutObjectQRCodeRecognitionRequest new];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = "exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    
    put.bucket = "examplebucket-1250000000";
    // 需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
    put.body = [@"My Example Content" dataUsingEncoding:NSUTF8StringEncoding];
    
    QCloudPicOperations *op = [[QCloudPicOperations alloc] init];
    // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
    op.is_pic_info = NO;
    QCloudPicOperationRule *rule = [[QCloudPicOperationRule alloc] init];
    //二维码识别的rule
    rule.rule = @"QRcode/cover/1";
    rule.fileid = @"test";
    op.rule = @[ rule ];
    req.picOperations = op;
    [req setFinishBlock:^(QCloudCIQRCodeRecognitionResults * _Nonnull result, NSError * _Nonnull error) {
        NSLog(@"识别的信息 = %@",result);
    }];
    [[QCloudCOSXMLService defaultCOSXML]PutObjectQRCodeRecognition:req];
    //.cssg-snippet-body-end
}

/**
 * 下载时进行二维码识别
 */
- (void)downloadWithQrcodeRecognition {
    //.cssg-snippet-body-start:[objc-download-with-qrcode-recognition]
    QCloudQRCodeRecognitionRequest *req = [QCloudQRCodeRecognitionRequest new];
    // 存储桶名称，格式为 BucketName-APPID
    put.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = @"exampleobject";

    QCloudPicOperations *op = [[QCloudPicOperations alloc] init];
    // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
    op.is_pic_info = NO;
    QCloudPicOperationRule * rule = [[QCloudPicOperationRule alloc]init];
    rule.fileid = @"test";
    //二维码识别的rule
    rule.rule = @"QRcode/cover/1";
    // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
    rule.fileid = @"test";
    op.rule = @[ rule ];
    req.picOperations = op;
    [req setFinishBlock:^(QCloudCIObject * _Nonnull result, NSError * _Nonnull error) {
        NSLog(@"result = %@",result);
    }];
    [[QCloudCOSXMLService defaultCOSXML] CIQRCodeRecognition:req];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma

- (void)testQrcodeRecognition {
    // 上传时进行二维码识别
    [self uploadWithQRcodeRecognition];
        
    // 下载时进行二维码识别
    [self downloadWithQrcodeRecognition];
        
    // .cssg-methods-pragma
}

@end
