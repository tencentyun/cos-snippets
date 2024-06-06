#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudPostSegmentVideoBodyRequest.h>

@interface PostSegmentVideoBodyDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation PostSegmentVideoBodyDemo

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

- (void) testPostSegmentVideoBody{
	QCloudPostSegmentVideoBodyRequest * request = [QCloudPostSegmentVideoBodyRequest new];
	request.bucket = @"sample-1250000000";
	request.regionName = @"COS_REGIONNAME";
	request.input = [QCloudPostSegmentVideoBody new];
	// 创建任务的 Tag：SegmentVideoBody;是否必传：是
	request.input.Tag = @"";
	// 待操作的对象信息;是否必传：是
	request.input.Input = [QCloudPostSegmentVideoBodyInput new];
	// 文件路径;是否必传：是
	request.input.Input.Object = @"";
	// 操作规则;是否必传：是
	request.input.Operation = [QCloudPostSegmentVideoBodyOperation new];
	// 视频人像抠图配置;是否必传：否
	request.input.Operation.SegmentVideoBody = [QCloudPostSegmentVideoBodySegmentVideoBody new];
	// 结果输出配置;是否必传：是
	request.input.Operation.Output = [QCloudPostSegmentVideoBodyOutput new];
	// 存储桶的地域;是否必传：是
	request.input.Operation.Output.Region = @"";
	// 存储结果的存储桶;是否必传：是
	request.input.Operation.Output.Bucket = @"";
	// 输出结果的文件名;是否必传：是
	request.input.Operation.Output.Object = @"";
	[request setFinishBlock:^(QCloudPostSegmentVideoBodyResponse * outputObject, NSError *error) {
		// result：QCloudPostSegmentVideoBodyResponse 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/83973
	}];
	[[QCloudCOSXMLService defaultCOSXML] PostSegmentVideoBody:request];

}

@end
