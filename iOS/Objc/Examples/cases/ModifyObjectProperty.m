#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface ModifyObjectProperty : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation ModifyObjectProperty

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
 * 修改对象元数据
 */
- (void)modifyObjectMetadata {
    
    //.cssg-snippet-body-start:[objc-modify-object-metadata]
    QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    
    // 是否拷贝元数据，枚举值：Copy，Replaced，默认值 Copy。
    // 假如标记为 Copy，忽略 Header 中的用户元数据信息直接复制
    // 假如标记为 Replaced，按 Header 信息修改元数据。当目标路径和原路径一致，即用户试图修改元数据时，必须为 Replaced
    request.metadataDirective = @"Replaced";
    
    // 自定义对象header
    [request.customHeaders setValue:@"newValue" forKey:@"x-cos-meta-*"];
    
    // 定义 Object 的 ACL 属性，有效值：private，public-read，default。
    // 默认值：default（继承 Bucket 权限）。
    // 注意：当前访问策略条目限制为1000条，如果您无需进行 Object ACL 控制，请填 default
    // 或者此项不进行设置，默认继承 Bucket 权限。
    request.accessControlList = @"default";
    // 源对象所在的路径
    request.objectCopySource =
        @"examplebucket-1250000000.cos.ap-guangzhou.myqcloud.com/exampleobject";
    
    [request setFinishBlock:^(QCloudCopyObjectResult * _Nonnull result,
                              NSError * _Nonnull error) {
        // result 返回具体信息
        
    }];
    [[QCloudCOSXMLService defaultCOSXML]  PutObjectCopy:request];
    
    //.cssg-snippet-body-end
    
}

/**
 * 修改对象存储类型
 */
- (void)modifyObjectStorageClass {
    
    //.cssg-snippet-body-start:[objc-modify-object-storage-class]
    QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    
    // 对象存储类型，枚举值请参见 存储类型 文档，例如 MAZ_STANDARD，MAZ_STANDARD_IA，
    // STANDARD_IA，ARCHIVE。仅当对象不是标准存储（STANDARD）时才会返回该头部
    [request.customHeaders setValue:@"ARCHIVE" forKey:@"x-cos-storage-class"];
    
    // 源对象所在的路径
    request.objectCopySource =
        @"examplebucket-1250000000.cos.ap-guangzhou.myqcloud.com/exampleobject";
    
    // 指定源文件的 versionID，只有开启或开启后暂停的存储桶，才会响应此参数
    request.versionID = @"";
    
    [request setFinishBlock:^(QCloudCopyObjectResult * _Nonnull result,
                              NSError * _Nonnull error) {
        // result 返回具体信息
       
    }];
    [[QCloudCOSXMLService defaultCOSXML]  PutObjectCopy:request];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma


- (void)testModifyObjectProperty {
    // 修改对象元数据
    [self modifyObjectMetadata];
    
    // 修改对象存储类型
    [self modifyObjectStorageClass];
    // .cssg-methods-pragma
    
}

@end
