#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketACL : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketACL

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
 * 设置存储桶 ACL
 */
- (void)putBucketAcl {
    

    //.cssg-snippet-body-start:[objc-put-bucket-acl]
    QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
    
    // 授予权限的账号 ID
    NSString* uin = @"100000000001";
    NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@"
                                 , uin,uin];
    NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
    
    // 赋予被授权者读写权限
    putACL.grantFullControl = grantString;
    
    // 赋予被授权者读权限
    putACL.grantRead = grantString;
    
    // 赋予被授权者写权限
    putACL.grantWrite = grantString;
    
    // 存储桶名称，格式为 BucketName-APPID
    putACL.bucket = @"examplebucket-1250000000";
    
    [putACL setFinishBlock:^(id outputObject, NSError *error) {
        // 可以从 outputObject 中获取服务器返回的 header 信息
        NSDictionary * result = (NSDictionary *)outputObject;

    }];
    // 设置acl
    [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
    
    //.cssg-snippet-body-end

}

/**
 * 获取存储桶 ACL
 */
- (void)getBucketAcl {
    
    //.cssg-snippet-body-start:[objc-get-bucket-acl]
    
    QCloudGetBucketACLRequest* getBucketACl = [QCloudGetBucketACLRequest new];
    
    // 存储桶名称，格式：BucketName-APPID
    getBucketACl.bucket = @"examplebucket-1250000000";
    
    [getBucketACl setFinishBlock:^(QCloudACLPolicy * _Nonnull result,
                                           NSError * _Nonnull error) {
        // 被授权者与权限的信息
        QCloudAccessControlList *acl = result.accessControlList;
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucketACL:getBucketACl];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma


- (void)testBucketACL {
    // 设置存储桶 ACL
    [self putBucketAcl];
        
    // 获取存储桶 ACL
    [self getBucketAcl];
    // .cssg-methods-pragma
        
}

@end
