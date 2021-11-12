#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface GetSnapshot : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation GetSnapshot

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
 * 用于查询已经开通媒体处理功能的存储桶
 */
-(void)getDescribeMediaBuckets{
    //.cssg-snippet-body-start:[objc-media-buckets]
    QCloudGetDescribeMediaBucketsRequest * reqeust = [[QCloudGetDescribeMediaBucketsRequest alloc]init];

    // 地域信息，例如 ap-shanghai、ap-beijing，若查询多个地域以“,”分隔字符串，支持中国大陆地域
    request.regions = regions;
    // 存储桶名称，以“,”分隔，支持多个存储桶，精确搜索
    request.bucketNames = bucketNames;
    // 存储桶名称前缀，前缀搜索
    request.bucketName = bucketName;
    // 第几页
    request.pageNumber = pageNumber;
    // 每页个数
    request.pageSize = pageSize;

    reqeust.finishBlock = ^(QCloudDescribeMediaInfo * outputObject, NSError *error) {
        // outputObject 请求到的媒体信息，详细字段请查看api文档或者SDK源码
        // QCloudDescribeMediaInfo  类；
    };
    [[QCloudCOSXMLService defaultCOSXML] CIGetDescribeMediaBuckets:reqeust];
    //.cssg-snippet-body-end
}

/**
 * 获取截图
 */
- (void)getSnapshot {
    //.cssg-snippet-body-start:[objc-get-snapshot]
    QCloudGetGenerateSnapshotRequest * reqeust = [[QCloudGetGenerateSnapshotRequest alloc]init];

    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    // 截图配置信息
    shotRequest.generateSnapshotConfiguration = [QCloudGenerateSnapshotConfiguration new];
    // 截取哪个时间点的内容，单位为秒 必传
    shotRequest.generateSnapshotConfiguration.time = 10;
    // 截图的宽。默认为0
    shotRequest.generateSnapshotConfiguration.width = 100;
    // 截图的宽。默认为0
    shotRequest.generateSnapshotConfiguration.height = 100;

    // 截帧方式:枚举值
    //  GenerateSnapshotModeExactframe：截取指定时间点的帧
    //  GenerateSnapshotModeKeyframe：截取指定时间点之前的最近的
    //  默认值为 exactframe
    shotRequest.generateSnapshotConfiguration.mode = GenerateSnapshotModeExactframe;

    // 图片旋转方式:枚举值
    // GenerateSnapshotRotateTypeAuto：按视频旋转信息进行自动旋转
    // GenerateSnapshotRotateTypeOff：不旋转
    // 默认值为 auto
    shotRequest.generateSnapshotConfiguration.rotate = GenerateSnapshotRotateTypeAuto;

    // 截图的格式:枚举值
    // GenerateSnapshotFormatJPG：jpg
    // GenerateSnapshotFormatPNG：png
    // 默认 jpg
    shotRequest.generateSnapshotConfiguration.format = GenerateSnapshotFormatJPG;

    reqeust.finishBlock = ^(QCloudGenerateSnapshotResult * outputObject, NSError *error) {
        // outputObject 截图信息，详细字段请查看api文档或者SDK源码
        // QCloudGenerateSnapshotResult  类；
    };
    [[QCloudCOSXMLService defaultCOSXML] GetGenerateSnapshot:reqeust];
    //.cssg-snippet-body-end
}

/**
 * 用于查询媒体文件的信息。
 */
-(void)getMediaInfo{
    //.cssg-snippet-body-start:[objc-get-media-info]
    QCloudGetMediaInfoRequest * reqeust = [[QCloudGetMediaInfoRequest alloc]init];
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    reqeust.finishBlock = ^(QCloudMediaInfo * outputObject, NSError *error) {
        // outputObject 请求到的媒体信息，详细字段请查看api文档或者SDK源码
        // QCloudMediaInfo 类；
    };
    [[QCloudCOSXMLService defaultCOSXML] CIGetMediaInfo:reqeust];
    //.cssg-snippet-body-end
}

// .cssg-methods-pragma

- (void)testGetSnapshot {
    
    // 用于查询已经开通媒体处理功能的存储桶
    [self getDescribeMediaBuckets];
    
    // 获取截图
    [self getSnapshot];
    
    // 用于查询媒体文件的信息。
    [self getMediaInfo];
        
    // .cssg-methods-pragma
}

@end
