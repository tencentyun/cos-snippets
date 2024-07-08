#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface ListObjects : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation ListObjects {
    QCloudListBucketResult* prevPageResult;
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
 * 获取首页对象列表
 */
- (void)getBucket {
    
    //.cssg-snippet-body-start:[objc-get-bucket]
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 单次返回的最大条目数量，默认1000
    request.maxKeys = 100;
    
    // 前缀匹配，用来规定返回的文件前缀地址
    request.prefix = @"dir1/";
    
    [request setFinishBlock:^(QCloudListBucketResult * result, NSError* error) {
        // result 返回具体信息
        // QCloudListBucketResult.contents 桶内文件数组
        // QCloudListBucketResult.commonPrefixes 桶内文件夹数组
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    //.cssg-snippet-body-end
    
}

/**
 * 获取第二页对象列表
 */
- (void)getBucketNextPage {
    
    //.cssg-snippet-body-start:[objc-get-bucket-next-page]
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // prevPageResult 是上一页的返回结果
    // 分页参数 默认以UTF-8二进制顺序列出条目，所有列出条目从marker开始
    request.marker = prevPageResult.nextMarker;
    
    // 单次返回的最大条目数量，默认1000
    request.maxKeys = 100;
    
    [request setFinishBlock:^(QCloudListBucketResult * result, NSError* error) {
        // result 返回具体信息
        // QCloudListBucketResult.contents 桶内文件数组
        // QCloudListBucketResult.commonPrefixes 桶内文件夹数组
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    //.cssg-snippet-body-end
}

/**
 * 获取对象列表与子目录
 */
- (void)getBucketWithDelimiter {

    //.cssg-snippet-body-start:[objc-get-bucket-with-delimiter]
    QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
    
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    
    // 单次返回的最大条目数量，默认1000
    request.maxKeys = 100;
    
    // 前缀匹配，用来规定返回的文件前缀地址
    request.prefix = @"dir1/";
    
    // 定界符为一个符号，如果有 Prefix，则将 Prefix 到 delimiter 之间的相同路径归为一类，
    // 定义为 Common Prefix，然后列出所有 Common Prefix。如果没有 Prefix，则从路径起点开始
    // delimiter:路径分隔符 固定为 /
    request.delimiter = @"/";
    
    // prevPageResult 是上一页的返回结果
    // 分页参数 默认以UTF-8二进制顺序列出条目，所有列出条目从marker开始
    request.marker = prevPageResult.nextMarker;
    
    [request setFinishBlock:^(QCloudListBucketResult * result, NSError* error) {
        // result 返回具体信息
        // QCloudListBucketResult.contents 桶内文件数组
        // QCloudListBucketResult.commonPrefixes 桶内文件夹数组
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
    
    //.cssg-snippet-body-end
    
}

- (void)selectObject {

    QCloudSelectObjectContentRequest *request = [QCloudSelectObjectContentRequest new];
    // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
    request.bucket = @"examplebucket-1250000000";
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    request.selectType = @"2";
    // 选择文件 配置
    QCloudSelectObjectContentConfig *config= [QCloudSelectObjectContentConfig new];
    /**SQL 表达式，代表您需要发起的检索操作。例如SELECT s._1 FROM COSObject s。
     这个表达式可以从 CSV 格式的对象中检索第一列内容。有关 SQL 表达式的详细介绍，
     请参见 (Select)[https://cloud.tencent.com/document/product/436/37636] 命令
    */
    config.express = @"select * from COSObject";
    /**
    表达式类型，该项为扩展项，目前只支持 SQL 表达式，仅支持 SQL 参数
    */
    config.expressionType = QCloudExpressionTypeSQL;
    /**
     描述待检索对象的格式
     */
    QCloudInputSerialization *inputS = [QCloudInputSerialization new];
    inputS.compressionType = QCloudCOSXMLCompressionTypeNONE;
    /**
    描述在JSON对象格式下所需的文件参数。
    */
    QCloudSerializationJSON *inputJson = [QCloudSerializationJSON new];
    /**
        SON 文件的类型：
        DOCUMENT 表示 JSON 文件仅包含一个独立的 JSON 对象，且该对象可以被切割成多行
        LINES 表示 JSON 对象中的每一行包含了一个独立的 JSON 对象
        合法值为 DOCUMENT 、LINES
        */
    inputJson.type = QCloudInputJSONFileTypeDocument;
    inputS.serializationJSON = inputJson;
    config.inputSerialization = inputS;
    /**
     描述检索结果的输出格式
     */
    QCloudOutputSerialization *outputS = [QCloudOutputSerialization new];
    
    QCloudSerializationJSON *outputJson = [QCloudSerializationJSON new];
    /**
        将输出结果中的记录分隔为不同行的字符，默认通过\n进行分隔。您可以指定任意8进制字符，
     如逗号、分号、Tab 等。该参数最多支持2个字节，即您可以输入\r\n这类格式的分隔符。默认值为\n
        */
    outputJson.outputRecordDelimiter = @"\n";
    /**
         描述在JSON对象格式下所需的文件参数。
         */
    outputS.serializationJSON = outputJson;
    
    config.outputSerialization = outputS;
    /**
     是否需要返回查询进度 QueryProgress 信息，如果选中 COS Select 将周期性返回查询进度
     */
    QCloudRequestProgress *requestProgress = [QCloudRequestProgress new];
    requestProgress.enabled = @"FALSE";
    config.requestProgress =requestProgress;
    request.selectObjectContentConfig  = config;
    /**
     文件存储在本地的路径
     */
    request.downloadingURL = [NSURL fileURLWithPath:QCloudFileInSubPath(@"test", @"2.json")];
    [request setDownProcessBlock:^(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload) {
        NSLog(@"⏬⏬⏬⏬DOWN [Total]%lld  [Downloaded]%lld [Download]%lld", totalBytesExpectedToDownload, totalBytesDownload, bytesDownload);
    }];
    
    [request setFinishBlock:^(id  _Nonnull result, NSError * _Nonnull error) {
        NSLog(@"result = %@",result);
    }];
    [[QCloudCOSXMLService defaultCOSXML] SelectObjectContent:request];
    
}
// .cssg-methods-pragma


- (void)testListObjects {
    // 获取对象列表
    [self getBucket];
    
    // 获取第二页对象列表
    [self getBucketNextPage];
    
    // 获取对象列表与子目录
    [self getBucketWithDelimiter];

    // 检索对象内容
    [self selectObject];
    // .cssg-methods-pragma
}

@end
