#import <QCloudCOSXML/QCloudCOSXML.h>

@interface AIEnhanceImageDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation AIEnhanceImageDemo

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

- (void) testAIEnhanceImage{
	QCloudAIEnhanceImageRequest * request = [QCloudAIEnhanceImageRequest new];
	request.bucket = @"sample-1250000000";
	request.regionName = @"COS_REGIONNAME";
	// 设置：ObjectKey;
	request.ObjectKey = ;
	// 数据万象处理能力，只能裁剪参固定为 AIEnhanceImage。;是否必传：true；
	request.ciProcess = @"AIEnhanceImage";
	// 去噪强度值，取值范围为 0 - 5 之间的整数，值为 0 时不进行去噪操作，默认值为3。;是否必传：false；
	request.denoise = 0;
	// 锐化强度值，取值范围为 0 - 5 之间的整数，值为 0 时不进行锐化操作，默认值为3。;是否必传：false；
	request.sharpen = 0;
	// 您可以通过填写 detect-url 处理任意公网可访问的图片链接。不填写 detect-url  时，后台会默认处理 ObjectKey ，填写了detect-url 时，后台会处理 detect-url链接，无需再填写 ObjectKey ，detect-url 示例：http://www.example.com/abc.jpg ，需要进行 UrlEncode，处理后为  http%25253A%25252F%25252Fwww.example.com%25252Fabc.jpg;是否必传：false；
	request.detectUrl = ;
	// ;是否必传：false；
	request.ignoreError = 0;
	[request setFinishBlock:^(id outputObject, NSError *error) {
		// 无响应体
	}];
	[[QCloudCOSXMLService defaultCOSXML] AIEnhanceImage:request];

}

@end
