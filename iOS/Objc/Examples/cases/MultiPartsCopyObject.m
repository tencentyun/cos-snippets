#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface MultiPartsCopyObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@property (nonatomic,copy)NSArray <QCloudMultipartInfo *>* parts;

@end

@implementation MultiPartsCopyObject {
    NSString* uploadId;
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

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue
requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
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
 * 初始化分块上传的方法
 *
 * 使用分块上传对象时，首先要进行初始化分片上传操作，获取对应分块上传的 uploadId，用于后续上传操
 * 作.分块上传适合于在弱网络或高带宽环境下上传较大的对象.SDK 支持自行切分对象并分别调用
 * uploadPart(UploadPartRequest)或者
 * uploadPartAsync(UploadPartRequest, CosXmlResultListener)上传各 个分块.
 */
- (void)initMultiUpload {
    
    //.cssg-snippet-body-start:[objc-init-multi-upload]
    QCloudInitiateMultipartUploadRequest* initrequest = [QCloudInitiateMultipartUploadRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    initrequest.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    initrequest.object = @"exampleobject";
    
    [initrequest setFinishBlock:^(QCloudInitiateMultipartUploadResult* outputObject,
                                  NSError *error) {
        // 获取分块上传的 uploadId，后续的上传都需要这个 ID，请保存以备后续使用
        self->uploadId = outputObject.uploadId;
       
    }];
    
    //初始化上传
    [[QCloudCOSXMLService defaultCOSXML] InitiateMultipartUpload:initrequest];
    
    //.cssg-snippet-body-end
    
}

/**
 * COS 中复制对象可以完成如下功能:
 * 创建一个新的对象副本.
 * 复制对象并更名，删除原始对象，实现重命名
 * 修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.
 * 在不同的腾讯云 COS 地域复制对象.修改对象的元数据，在复制时选择相同的源和目标对象键，
 * 并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.
 */
- (void)uploadPartCopy {
    
    //.cssg-snippet-body-start:[objc-upload-part-copy]
    QCloudUploadPartCopyRequest* request = [[QCloudUploadPartCopyRequest alloc] init];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    
    // 源文件 URL 路径，可以通过 versionid 子资源指定历史版本
    request.source = @"sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject";
    
    // 在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
    request.uploadID = uploadId;
    
    // 标志当前分块的序号
    request.partNumber = 1;
    
    [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
        QCloudMultipartInfo *part = [QCloudMultipartInfo new];
        
        // 获取所复制分块的 etag
        part.eTag = result.eTag;
        part.partNumber = @"1";
        // 保存起来用于最后完成上传时使用
        self.parts=@[part];
        
    }];
    
    [[QCloudCOSXMLService defaultCOSXML]UploadPartCopy:request];
    
    //.cssg-snippet-body-end

}

/**
 * 当使用分块上传（uploadPart(UploadPartRequest)）完对象的所有块以后，必须调用该
 * completeMultiUpload(CompleteMultiUploadRequest) 或者
 * completeMultiUploadAsync(CompleteMultiUploadRequest, CosXmlResultListener)
 * 来完成整个文件的分块上传.且在该请求的 Body 中需要给出每一个块的 PartNumber 和 ETag，
 * 用来校验块的准 确性.
 */
- (void)completeMultiUpload {
    
    //.cssg-snippet-body-start:[objc-complete-multi-upload]
    QCloudCompleteMultipartUploadRequest *completeRequst = [QCloudCompleteMultipartUploadRequest new];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    completeRequst.object = @"exampleobject";
    
    // 存储桶名称，格式为 BucketName-APPID
    completeRequst.bucket = @"examplebucket-1250000000";
    
    // 本次要查询的分块上传的 uploadId，可从初始化分块上传的请求结果 QCloudInitiateMultipartUploadResult 中得到
    completeRequst.uploadId = @"exampleUploadId";
    
    // 在进行HTTP请求的时候，可以通过设置该参数来设置自定义的一些头部信息。
    // 通常情况下，携带特定的额外HTTP头部可以使用某项功能，如果是这类需求，
    // 可以通过设置该属性来实现。
    [completeRequst.customHeaders setValue:@"" forKey:@""];
    
    // 已上传分块的信息
    QCloudCompleteMultipartUploadInfo *partInfo = [QCloudCompleteMultipartUploadInfo new];
    
    NSMutableArray * parts = [self.parts mutableCopy];
    // 对已上传的块进行排序
    [parts sortUsingComparator:^NSComparisonResult(QCloudMultipartInfo*  _Nonnull obj1,
                                                   QCloudMultipartInfo*  _Nonnull obj2) {
          int a = obj1.partNumber.intValue;
          int b = obj2.partNumber.intValue;
          
          if (a < b) {
              return NSOrderedAscending;
          } else {
              return NSOrderedDescending;
          }
      }];
    partInfo.parts = [parts copy];
    
    completeRequst.parts = partInfo;
    [completeRequst setFinishBlock:^(QCloudUploadObjectResult * _Nonnull result,
                                     NSError * _Nonnull error) {
        // 从 result 中获取上传结果
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] CompleteMultipartUpload:completeRequst];
    
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testMultiPartsCopyObject {
    // 初始化分片上传
    [self initMultiUpload];
    
    // 拷贝一个分片
    [self uploadPartCopy];
    
    // 完成分片拷贝任务
    [self completeMultiUpload];
    // .cssg-methods-pragma
    
}

@end
