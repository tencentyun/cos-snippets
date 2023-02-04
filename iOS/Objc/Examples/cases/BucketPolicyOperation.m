#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudCIDetectCarRequest.h>
@interface BucketPolicyOperation : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketPolicyOperation

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
 *PUT Bucket policy
 */
- (void)putBucketPolicy{
    //.cssg-snippet-body-start:[cssg-snippet-put-bucket-policy]
    QCloudPutBucketPolicyRequest * request = [QCloudPutBucketPolicyRequest new];
    // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
    request.bucket = @"0-1250000000";
    request.regionName = @"ap-chengdu";
    // 权限策略，详情请参见 访问管理策略语法 https://cloud.tencent.com/document/product/436/12469#.E7.AD.96.E7.95.A5.E8.AF.AD.E6.B3.95
    request.policyInfo = @{
        @"Statement": @[
            @{
            @"Principal": @{
                @"qcs": @[
                @"qcs::cam::uin/100000000001:uin/100000000001"
                ]
            },
            @"Effect": @"allow",
            @"Action": @[
                @"name/cos:GetBucket"
            ],
            @"Resource": @[
                @"qcs::cos:ap-guangzhou:uid/1250000000:examplebucket-1250000000/*"
            ]
            }
        ],
        @"version": @"2.0"
        };
    [request setFinishBlock:^(id  _Nullable outputObject, NSError * _Nullable error) {
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketPolicy:request];
    //.cssg-snippet-body-end
}

/**
 * GET Bucket policy
 */
- (void)getBucketPolicy{
    //.cssg-snippet-body-start:[cssg-snippet-get-bucket-policy]
    QCloudGetBucketPolicyRequest * request = [QCloudGetBucketPolicyRequest new];
    // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
    request.bucket = @"bucketname-appid";
    request.regionName = @"ap-chengdu";
    [request setFinishBlock:^(QCloudBucketPolicyResult * _Nullable outputObject, NSError * _Nullable error) {
        // QCloudBucketPolicyResult 详细字段请查看api文档或者SDK源码
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketPolicy:request];
    //.cssg-snippet-body-end
}

/**
 *PUT Bucket policy
 */
- (void)deleteBucketPolicy{
    //.cssg-snippet-body-start:[cssg-snippet-delete-bucket-policy]
    QCloudDeleteBucketPolicyRequest * request = [QCloudDeleteBucketPolicyRequest new];
    request.bucket = @"0-1253960454";
    request.regionName = @"ap-chengdu";
    [request setFinishBlock:^(id  _Nullable outputObject, NSError * _Nullable error) {
        /// error 为空则表示成功
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketPolicy:request];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma
- (void)testBucketPolicy {
    
    [self putBucketPolicy];
    
    [self getBucketPolicy];
    
    [self deleteBucketPolicy];
  
    // .cssg-methods-pragma
}

@end
