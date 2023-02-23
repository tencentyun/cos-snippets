import XCTest
import QCloudCOSXML

class BucketPolicy: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

    var credentialFenceQueue:QCloudCredentailFenceQueue?;

    override func setUp() {
        let config = QCloudServiceConfiguration.init();
        config.signatureProvider = self;
        config.appID = "1253653367";
        let endpoint = QCloudCOSXMLEndPoint.init();
        endpoint.regionName = "ap-guangzhou";//服务地域名称，可用的地域请参考注释
        endpoint.useHTTPS = true;
        config.endpoint = endpoint;
        QCloudCOSXMLService.registerDefaultCOSXML(with: config);
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: config);

        // 脚手架用于获取临时密钥
        self.credentialFenceQueue = QCloudCredentailFenceQueue();
        self.credentialFenceQueue?.delegate = self;
    }

    func fenceQueue(_ queue: QCloudCredentailFenceQueue!,
                    requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let cre = QCloudCredential.init();
        //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
        cre.secretID = "COS_SECRETID";
        cre.secretKey = "COS_SECRETKEY";
        cre.token = "COS_TOKEN";
        /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
        cre.startDate = DateFormatter().date(from: "startTime"); // 单位是秒
        cre.expirationDate = DateFormatter().date(from: "expiredTime");
        let auth = QCloudAuthentationV5Creator.init(credential: cre);
        continueBlock(auth,nil);
    }

    func signature(with fileds: QCloudSignatureFields!,
                   request: QCloudBizHTTPRequest!,
                   urlRequest urlRequst: NSMutableURLRequest!,
                   compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        self.credentialFenceQueue?.performAction({ (creator, error) in
            if error != nil {
                continueBlock(nil,error!);
            }else{
                let signature = creator?.signature(forData: urlRequst);
                continueBlock(signature,nil);
            }
        })
    }

    // 设置存储桶 Policy
    func putBucketPolicy() {
      
        //.cssg-snippet-body-start:[swift-put-bucket-policy]
        let request = QCloudPutBucketPolicyRequest.init();
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        request.bucket = "0-1250000000";
        request.regionName = "ap-chengdu";
        // 权限策略，详情请参见 访问管理策略语法 https://cloud.tencent.com/document/product/436/12469#.E7.AD.96.E7.95.A5.E8.AF.AD.E6.B3.95
        request.policyInfo = [
            "Statement": [
                [
                "Principal": [
                    "qcs": [
                    "qcs::cam::uin/100000000001:uin/100000000001"
                    ]
                ],
                "Effect": "allow",
                "Action": [
                    "name/cos:GetBucket"
                ],
                "Resource": [
                    "qcs::cos:ap-guangzhou:uid/1250000000:examplebucket-1250000000/*"
                ]
                ]
            ],
            "version": "2.0"
            ];
        request.finishBlock = {(result,error) in
            
        }
        QCloudCOSXMLService.defaultCOSXML().putBucketPolicy(request);
        //.cssg-snippet-body-end

    }

    // 获取存储桶 Policy
    func getBucketPolicy() {
      
        //.cssg-snippet-body-start:[swift-get-bucket-policy]
        let request = QCloudGetBucketPolicyRequest.init();
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        request.bucket = "bucketname-appid";
        request.regionName = "ap-chengdu";
        request.finishBlock = {(result,error) in
            // QCloudBucketPolicyResult 详细字段请查看api文档或者SDK源码
        }
        QCloudCOSXMLService.defaultCOSXML().getBucketPolicy(request);
        //.cssg-snippet-body-end
          
    }

    // 删除存储桶 Policy
    func deleteBucketPolicy() {
      
        //.cssg-snippet-body-start:[swift-delete-bucket-policy]
        let  request = QCloudDeleteBucketPolicyRequest.init();
        request.bucket = "0-1253960454";
        request.regionName = "ap-chengdu";
        request.finishBlock = {(result,error) in
            /// error 为空则表示成功
        }
        QCloudCOSXMLService.defaultCOSXML().deleteBucketPolicy(request);
        //.cssg-snippet-body-end

    }
    // .cssg-methods-pragma

    func testBucketPolicy() {
        // 设置存储桶 Policy
        self.putBucketPolicy();
        // 获取存储桶 Policy
        self.getBucketPolicy();
        // 删除存储桶 Policy
        self.deleteBucketPolicy();
        // .cssg-methods-pragma
    }
}
