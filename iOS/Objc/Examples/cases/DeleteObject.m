#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface DeleteObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation DeleteObject

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
 * 删除对象
 */
- (void)deleteObject {

    //.cssg-snippet-body-start:[objc-delete-object]
    QCloudDeleteObjectRequest* deleteObjectRequest = [QCloudDeleteObjectRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    deleteObjectRequest.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    deleteObjectRequest.object = @"exampleobject";
    
    [deleteObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
    
    //.cssg-snippet-body-end

    
}

/**
 * 删除多个对象
 */
- (void)deleteMultiObject {

    //.cssg-snippet-body-start:[objc-delete-multi-object]
    QCloudDeleteMultipleObjectRequest* delteRequest = [QCloudDeleteMultipleObjectRequest new];
    delteRequest.bucket = @"examplebucket-1250000000";
    
    // 要删除的单个文件
    QCloudDeleteObjectInfo* deletedObject0 = [QCloudDeleteObjectInfo new];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    deletedObject0.key = @"exampleobject";
    
    // 要删除的文件集合
    QCloudDeleteInfo* deleteInfo = [QCloudDeleteInfo new];
    
    // 布尔值，这个值决定了是否启动 Quiet 模式：
    // true：启动 Quiet 模式
    // false：启动 Verbose 模式
    // 默认值为 False
    deleteInfo.quiet = NO;
    
    // 存放需要删除对象信息的数组
    deleteInfo.objects = @[deletedObject0];
    
    // 封装了需要批量删除的多个对象的信息
    delteRequest.deleteObjects = deleteInfo;
    
    [delteRequest setFinishBlock:^(QCloudDeleteResult* outputObject,
                                   NSError *error) {
        // 可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
        
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:delteRequest];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma

- (void)testDeleteObject {
    // 删除对象
    [self deleteObject];
        
    // 删除多个对象
    [self deleteMultiObject];
    // .cssg-methods-pragma
        
}

@end
