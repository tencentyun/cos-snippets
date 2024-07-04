#import <QCloudCOSXML/QCloudCOSXML.h>
#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXMLService+MateData.h>
@interface DatasetFaceSearchDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation DatasetFaceSearchDemo

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

- (void) testDatasetFaceSearch{
	QCloudDatasetFaceSearchRequest * request = [QCloudDatasetFaceSearchRequest new];
	request.regionName = @"COS_REGIONNAME";
	request.input = [QCloudDatasetFaceSearch new];
	// 数据集名称，同一个账户下唯一。;是否必传：是
	request.input.DatasetName = @"test";
	// 资源标识字段，表示需要建立索引的文件地址。;是否必传：是
	request.input.URI = @"cos://examplebucket-1250000000/test.jpg";
	// 输入图片中检索的人脸数量，默认值为1(传0或不传采用默认值)，最大值为10。;是否必传：否
	request.input.MaxFaceNum = 1;
	// 检索的每张人脸返回相关人脸数量，默认值为10，最大值为100。;是否必传：否
	request.input.Limit = 10;
	// 限制返回人脸的最低相关度分数，只有超过 MatchThreshold 值的人脸才会返回。默认值为0，推荐值为80。 例如：设置 MatchThreshold 的值为80，则检索结果中仅会返回相关度分数大于等于80分的人脸。;是否必传：否
	request.input.MatchThreshold = 10;
	[request setFinishBlock:^(QCloudDatasetFaceSearchResponse * outputObject, NSError *error) {
		// result：QCloudDatasetFaceSearchResponse 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106166
	}];
	[[QCloudCOSXMLService defaultCOSXML] DatasetFaceSearch:request];

}

@end
