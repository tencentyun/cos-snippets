#import <QCloudCOSXML/QCloudCOSXML.h>
#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXMLService+MateData.h>
@interface DatasetSimpleQueryDemo : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation DatasetSimpleQueryDemo

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

- (void) testDatasetSimpleQuery{
	QCloudDatasetSimpleQueryRequest * request = [QCloudDatasetSimpleQueryRequest new];
	request.regionName = @"COS_REGIONNAME";
	request.input = [QCloudDatasetSimpleQuery new];
	// 数据集名称，同一个账户下唯一。;是否必传：是
	request.input.DatasetName = @"test";
	// 简单查询参数条件，可自嵌套。;是否必传：否
	request.input.Query = [QCloudQuery new];
	// 操作运算符。枚举值： not：逻辑非。 or：逻辑或。 and：逻辑与。 lt：小于。 lte：小于等于。 gt：大于。 gte：大于等于。 eq：等于。 exist：存在性查询。 prefix：前缀查询。 match-phrase：字符串匹配查询。 nested：字段为数组时，其中同一对象内逻辑条件查询。;是否必传：是
	request.input.Query.Operation = @"and";
	// 子查询的结构体。 只有当Operations为逻辑运算符（and、or、not或nested）时，才能设置子查询条件。 在逻辑运算符为and/or/not时，其SubQueries内描述的所有条件需符合父级设置的and/or/not逻辑关系。 在逻辑运算符为nested时，其父级的Field必须为一个数组类的字段（如：Labels）。 子查询条件SubQueries组的Operation必须为and/or/not中的一个或多个，其Field必须为父级Field的子属性。;是否必传：否
	request.input.Query.SubQueries = [QCloudSubQueries new];
	// 返回文件元数据的最大个数，取值范围为0200。 使用聚合参数时，该值表示返回分组的最大个数，取值范围为02000。 不设置此参数或者设置为0时，则取默认值100。;是否必传：否
	request.input.MaxResults = 100;
	// 排序字段列表。请参考[字段和操作符的支持列表](https://cloud.tencent.com/document/product/460/106154)。 多个排序字段可使用半角逗号（,）分隔，例如：Size,Filename。 最多可设置5个排序字段。 排序字段顺序即为排序优先级顺序。;是否必传：否
	request.input.Sort = @"CustomId";
	// 排序字段的排序方式。取值如下： asc：升序； desc（默认）：降序。 多个排序方式可使用半角逗号（,）分隔，例如：asc,desc。 排序方式不可多于排序字段，即参数Order的元素数量需小于等于参数Sort的元素数量。例如Sort取值为Size,Filename时，Order可取值为asc,desc或asc。 排序方式少于排序字段时，未排序的字段默认取值asc。例如Sort取值为Size,Filename，Order取值为asc时，Filename默认排序方式为asc，即升序排列;是否必传：否
	request.input.Order = @"desc";
	[request setFinishBlock:^(QCloudDatasetSimpleQueryResponse * outputObject, NSError *error) {
		// result：QCloudDatasetSimpleQueryResponse 包含所有的响应；
		// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/106375
	}];
	[[QCloudCOSXMLService defaultCOSXML] DatasetSimpleQuery:request];

}

@end
