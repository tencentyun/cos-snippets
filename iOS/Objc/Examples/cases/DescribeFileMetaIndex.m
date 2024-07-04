#import <QCloudCOSXML/QCloudCOSXML.h>
#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudDescribeFileMetaIndexRequest.h>
#import <QCloudCOSXML/QCloudCOSXMLService+MateData.h>
@interface DescribeFileMetaIndexDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation DescribeFileMetaIndexDemo

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

- (void) testDescribeFileMetaIndex{
	QCloudDescribeFileMetaIndexRequest * request = [QCloudDescribeFileMetaIndexRequest new];
	request.regionName = @"COS_REGIONNAME";
	// 数据集名称，同一个账户下唯一。;是否必传：true；
	request.datasetname = @"数据集名称";
	// 资源标识字段，表示需要建立索引的文件地址，当前仅支持 COS 上的文件，字段规则：cos://<BucketName>/<ObjectKey>，其中BucketName表示 COS 存储桶名称，ObjectKey 表示文件完整路径，例如：cos://examplebucket-1250000000/test1/img.jpg。 注意： 仅支持本账号内的 COS 文件 不支持 HTTP 开头的地址 需 UrlEncode;是否必传：true；
	request.uri = @"cos://facesearch-12500000000";
	[request setFinishBlock:^(QCloudDescribeFileMetaIndexResponse * outputObject, NSError *error) {
		// result：QCloudDescribeFileMetaIndexResponse 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106164
	}];
	[[QCloudCOSXMLService defaultCOSXML] DescribeFileMetaIndex:request];

}

@end
