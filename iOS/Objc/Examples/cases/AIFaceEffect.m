#import <QCloudCOSXML/QCloudCOSXML.h>

@interface AIFaceEffectDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation AIFaceEffectDemo

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

- (void) testAIFaceEffect{
    QCloudCIFaceEffectRequest * request = [QCloudCIFaceEffectRequest new];
	request.bucket = @"sample-1250000000";
	request.regionName = @"COS_REGIONNAME";
	// 设置：ObjectKey;
	request.ObjectKey = ;
	// 万象处理能力，人脸特效固定为face-effect;是否必传：true；
	request.ciProcess = @"face-effect";
	// 您可以通过填写 detect-url 处理任意公网可访问的图片链接。不填写 detect-url 时，后台会默认处理 ObjectKey ，填写了 detect-url 时，后台会处理 detect-url 链接，无需再填写 ObjectKey detect-url 示例：http://www.example.com/abc.jpg ，需要进行 UrlEncode，处理后为http%25253A%25252F%25252Fwww.example.com%25252Fabc.jpg。;是否必传：false；
	request.detectUrl = ;
	// 人脸特效类型，人脸美颜：face-beautify；人脸性别转换：face-gender-transformation；人脸年龄变化：face-age-transformation；人像分割：face-segmentation;是否必传：true；
	request.type = ;
	// type为face-beautify时生效，美白程度，取值范围[0,100]。0不美白，100代表最高程度。默认值30;是否必传：false；
	request.whitening = 0;
	// type为face-beautify时生效，磨皮程度，取值范围[0,100]。0不磨皮，100代表最高程度。默认值10;是否必传：false；
	request.smoothing = 0;
	// type为face-beautify时生效，瘦脸程度，取值范围[0,100]。0不瘦脸，100代表最高程度。默认值70;是否必传：false；
	request.faceLifting = 0;
	// type为face-beautify时生效，大眼程度，取值范围[0,100]。0不大眼，100代表最高程度。默认值70;是否必传：false；
	request.eyeEnlarging = 0;
	// type为face-gender-transformation时生效，选择转换方向，0：男变女，1：女变男。无默认值，为必选项。限制：仅对图片中面积最大的人脸进行转换。;是否必传：false；
	request.gender = 0;
	// type为face-age-transformation时生效，变化到的人脸年龄,[10,80]。无默认值，为必选项。限制：仅对图片中面积最大的人脸进行转换。;是否必传：false；
	request.age = 0;
	[request setFinishBlock:^(QCloudEffectFaceResult * outputObject, NSError *error) {
		// result：QCloudEffectFaceResult 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/47197
	}];
	[[QCloudCOSXMLService defaultCOSXML] FaceEffect:request];

}

@end
