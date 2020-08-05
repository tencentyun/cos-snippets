#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface HeadObject : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation HeadObject

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
 * 1:HEAD Object 接口请求可以判断指定对象是否存在和有权限，并在指定对象可访问时获取其元数据。
 * 该 API 的请求者需要对目标对象有读取权限，或者目标对象向所有人开放了读取权限（公有读）。
 *
 * 2:当启用版本控制时，该 HEAD 操作可以使用 versionId 请求参数指定要返回的版本 ID，此时将返回
 * 指定版本的元数据，如指定版本为删除标记则返回 HTTP 响应码404（Not Found），否则将返回最新
 * 版本的元数据。
 */
- (void)headObject {

    //.cssg-snippet-body-start:[objc-head-object]
    QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    headerRequest.object = @"exampleobject";
    
    // versionId 当启用版本控制时，指定要查询的版本 ID，如不指定则查询对象的最新版本
    headerRequest.versionID = @"versionID";
    
    // 存储桶名称，格式为 BucketName-APPID
    headerRequest.bucket = @"examplebucket-1250000000";
    
    [headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
        // result 返回具体信息

    }];
    
    [[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
    
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma


- (void)testHeadObject {
    // 获取对象信息
    [self headObject];
    // .cssg-methods-pragma
    
}

@end
