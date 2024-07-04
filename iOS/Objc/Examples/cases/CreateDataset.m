#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudCOSXMLService+MateData.h>
@interface CreateDatasetDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation CreateDatasetDemo

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

- (void) testCreateDataset{
	QCloudCreateDatasetRequest * request = [QCloudCreateDatasetRequest new];
	request.regionName = @"COS_REGIONNAME";
	request.input = [QCloudCreateDataset new];
	// 数据集名称，同一个账户下唯一。命名规则如下： 长度为1~32字符。 只能包含小写英文字母，数字，短划线（-）。 必须以英文字母和数字开头。;是否必传：是
	request.input.DatasetName = @"test";
	// 数据集描述信息。长度为1~256个英文或中文字符，默认值为空。;是否必传：否
	request.input.Description = @"test";
	//  与数据集关联的检索模板，在建立元数据索引时，后端将根据检索模板来决定采集文件的哪些元数据。每个检索模板都包含若干个算子，不同的算子表示不同的处理能力，更多信息请参见 [检索模板与算子](https://cloud.tencent.com/document/product/460/106018)。 默认值为空，即不关联检索模板，不进行任何元数据的采集。;是否必传：否
	request.input.TemplateId = @"Official:COSBasicMeta";
	[request setFinishBlock:^(QCloudCreateDatasetResponse * outputObject, NSError *error) {
		// result：QCloudCreateDatasetResponse 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106020
	}];
	[[QCloudCOSXMLService defaultCOSXML] CreateDataset:request];

}

@end
