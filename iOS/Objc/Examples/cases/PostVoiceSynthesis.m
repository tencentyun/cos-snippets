#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudPostVoiceSynthesisRequest.h>

@interface PostVoiceSynthesisDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation PostVoiceSynthesisDemo

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

- (void) testPostVoiceSynthesis{
	QCloudPostVoiceSynthesisRequest * request = [QCloudPostVoiceSynthesisRequest new];
	request.bucket = @"sample-1250000000";
	request.regionName = @"COS_REGIONNAME";
	request.input = [QCloudPostVoiceSynthesis new];
	// 创建任务的 Tag：Tts;是否必传：是
	request.input.Tag = @"";
	// 操作规则;是否必传：是
	request.input.Operation = [QCloudPostVoiceSynthesisOperation new];
	// 语音合成参数;是否必传：否
	request.input.Operation.TtsTpl = [QCloudPostVoiceSynthesisTtsTpl new];
	// 语音合成任务参数;是否必传：是
	request.input.Operation.TtsConfig = [QCloudPostVoiceSynthesisTtsConfig new];
	// 输入类型，Url/Text;是否必传：是
	request.input.Operation.TtsConfig.InputType = @"";
	// 当 InputType 为 Url 时， 必须是合法的 COS 地址，文件必须是utf-8编码，且大小不超过 10M。如果合成方式为同步处理，则文件内容不超过 300 个 utf-8 字符；如果合成方式为异步处理，则文件内容不超过 10000 个 utf-8 字符。当 InputType 为 Text 时, 输入必须是 utf-8 字符, 且不超过 300 个字符。;是否必传：是
	request.input.Operation.TtsConfig.Input = @"";
	// 结果输出配置;是否必传：是
	request.input.Operation.Output = [QCloudPostVoiceSynthesisOutput new];
	// 存储桶的地域;是否必传：是
	request.input.Operation.Output.Region = @"";
	// 存储结果的存储桶;是否必传：是
	request.input.Operation.Output.Bucket = @"";
	// 结果文件名;是否必传：是
	request.input.Operation.Output.Object = @"";
	[request setFinishBlock:^(QCloudPostVoiceSynthesisResponse * outputObject, NSError *error) {
		// result：QCloudPostVoiceSynthesisResponse 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/84797
	}];
	[[QCloudCOSXMLService defaultCOSXML] PostVoiceSynthesis:request];

}

@end
