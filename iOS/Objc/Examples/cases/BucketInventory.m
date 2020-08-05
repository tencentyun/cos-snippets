#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketInventory : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketInventory

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
 * 设置存储桶清单任务
 */
- (void)putBucketInventory {
    
    //.cssg-snippet-body-start:[objc-put-bucket-inventory]
    QCloudPutBucketInventoryRequest *putReq = [QCloudPutBucketInventoryRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    putReq.bucket= @"examplebucket-1250000000";
    
    // 清单任务的名称
    putReq.inventoryID = @"list1";
    
    // 用户在请求体中使用 XML 语言设置清单任务的具体配置信息。配置信息包括清单任务分析的对象，
    // 分析的频次，分析的维度，分析结果的格式及存储的位置等信息。
    QCloudInventoryConfiguration *config = [QCloudInventoryConfiguration new];
    
    // 清单的名称，与请求参数中的 id 对应
    config.identifier = @"list1";
    
    // 清单是否启用的标识：
    // 如果设置为 true，清单功能将生效
    // 如果设置为 false，将不生成任何清单
    config.isEnabled = @"True";
    
    // 描述存放清单结果的信息
    QCloudInventoryDestination *des = [QCloudInventoryDestination new];
    
    QCloudInventoryBucketDestination *btDes =[QCloudInventoryBucketDestination new];
    
    // 清单分析结果的文件形式，可选项为 CSV 格式
    btDes.cs = @"CSV";
    
    // 存储桶的所有者 ID
    btDes.account = @"1278687956";
    
    // 存储桶名称，格式为 BucketName-APPID
    btDes.bucket  = @"qcs::cos:ap-guangzhou::examplebucket-1250000000";
    
    // 清单分析结果的前缀
    btDes.prefix = @"list1";
    
    // COS 托管密钥的加密方式
    QCloudInventoryEncryption *enc = [QCloudInventoryEncryption new];
    enc.ssecos = @"";
    
    // 为清单结果提供服务端加密的选项
    btDes.encryption = enc;
    
    // 清单结果导出后存放的存储桶信息
    des.bucketDestination = btDes;
    
    // 描述存放清单结果的信息
    config.destination = des;
    
    // 配置清单任务周期
    QCloudInventorySchedule *sc = [QCloudInventorySchedule new];
    
    // 清单任务周期，可选项为按日或者按周，枚举值：Daily、Weekly
    sc.frequency = @"Daily";
    config.schedule = sc;
    QCloudInventoryFilter *fileter = [QCloudInventoryFilter new];
    fileter.prefix = @"myPrefix";
    config.filter = fileter;
    config.includedObjectVersions = QCloudCOSIncludedObjectVersionsAll;
    QCloudInventoryOptionalFields *fields = [QCloudInventoryOptionalFields new];
    
    fields.field = @[ @"Size",
                      @"LastModifiedDate",
                      @"ETag",
                      @"StorageClass",
                      @"IsMultipartUploaded",
                      @"ReplicationStatus"];
    
    // 设置清单结果中应包含的分析项目
    config.optionalFields = fields;
    putReq.inventoryConfiguration = config;
    [putReq setFinishBlock:^(id outputObject, NSError *error) {
        // 可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
        NSDictionary * result = (NSDictionary *)outputObject;

    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketInventory:putReq];
    
    //.cssg-snippet-body-end
}

/**
 * 获取存储桶清单任务
 */
- (void)getBucketInventory {

    //.cssg-snippet-body-start:[objc-get-bucket-inventory]
    QCloudGetBucketInventoryRequest *getReq = [QCloudGetBucketInventoryRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    getReq.bucket = @"examplebucket-1250000000";
    
    // 清单任务的名称
    getReq.inventoryID = @"list1";
    [getReq setFinishBlock:^(QCloudInventoryConfiguration * _Nonnull result,
                             NSError * _Nonnull error) {
        // result 包含清单的信息
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketInventory:getReq];
    
    //.cssg-snippet-body-end

}

/**
 * 删除存储桶清单任务
 */
- (void)deleteBucketInventory {

    //.cssg-snippet-body-start:[objc-delete-bucket-inventory]
    QCloudDeleteBucketInventoryRequest *delReq = [QCloudDeleteBucketInventoryRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    delReq.bucket = @"examplebucket-1250000000";
    
    // 清单任务的名称
    delReq.inventoryID = @"list1";
    [delReq setFinishBlock:^(id outputObject, NSError *error) {
        // 可以从 outputObject 中获取 response 中 etag 或者自定义头部等信息
        NSDictionary * result = (NSDictionary *)outputObject;
        
    }];
    [[QCloudCOSXMLService defaultCOSXML] DeleteBucketInventory:delReq];
    
    //.cssg-snippet-body-end

}
// .cssg-methods-pragma

- (void)testBucketInventory {
    // 设置存储桶清单任务
    [self putBucketInventory];
        
    // 获取存储桶清单任务
    [self getBucketInventory];
        
    // 删除存储桶清单任务
    [self deleteBucketInventory];
    // .cssg-methods-pragma
        
}

@end
