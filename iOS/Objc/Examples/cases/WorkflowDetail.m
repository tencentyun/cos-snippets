#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudGetWorkflowDetailRequest.h>
#import <QCloudCOSXML/QCloudGetListWorkflowRequest.h>
@interface WorkflowDetail : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation WorkflowDetail

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
 * 获取工作流实例详情
 */
- (void)GetWorkflowDetail{
    
    QCloudGetWorkflowDetailRequest * detailRequest = [QCloudGetWorkflowDetailRequest new];

    // 存储桶名称，格式为 BucketName-APPID
    detailRequest.bucket = @"examplebucket-1250000000";
    // 文件所在地域
    detailRequest.regionName = @"regionName";
    // 为工作流实例id
    detailRequest.runId = @"runId";
    [detailRequest setFinishBlock:^(QCloudWorkflowexecutionResult * _Nullable result, NSError * _Nullable error) {
        // result 获取工作流实例详情 ，详细字段请查看 API 文档或者 SDK 源码
    }];
    [[QCloudCOSXMLService defaultCOSXML]GetWorkflowDetail:detailRequest];


}

/**
 * 查询工作流
 */
- (void)GetListWorkflow{
    
    QCloudGetListWorkflowRequest * request = [QCloudGetListWorkflowRequest new];
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    // 文件所在地域
    request.regionName = @"regionName";
    // 工作流 ID，以,符号分割字符串
    request.ids = @"ids";
    // 工作流名称
    request.name = @"name";
    [request setFinishBlock:^(QCloudListWorkflow * _Nullable result, NSError * _Nullable error) {
        // result 查询工作流 ，详细字段请查看 API 文档或者 SDK 源码
    }];
    [QCloudCOSXMLService.defaultCOSXML GetListWorkflow:request];

}
@end
