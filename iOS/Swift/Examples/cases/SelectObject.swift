import XCTest
import QCloudCOSXML

class SelectObject: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

    func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let cre = QCloudCredential.init();
        //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
        cre.secretID = "COS_SECRETID";
        cre.secretKey = "COS_SECRETKEY";
        cre.token = "COS_TOKEN";
        /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
        cre.startDate = DateFormatter().date(from: "startTime"); // 单位是秒
        cre.experationDate = DateFormatter().date(from: "expiredTime");
        let auth = QCloudAuthentationV5Creator.init(credential: cre);
        continueBlock(auth,nil);
    }

    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        self.credentialFenceQueue?.performAction({ (creator, error) in
            if error != nil {
                continueBlock(nil,error!);
            }else{
                let signature = creator?.signature(forData: urlRequst);
                continueBlock(signature,nil);
            }
        })
    }


    // 检索对象内容
    func selectObject() {
        //.cssg-snippet-body-start:[swift-select-object]
        let request = QCloudSelectObjectContentRequest.init();
        // 存储桶名称，格式为 BucketName-APPID
        request.bucket = "examplebucket-1250000000";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
        request.object = "exampleobject";
        //代表这一接口的版本信息
        request.selectType = "2";
        // 选择文件 配置
        let config = QCloudSelectObjectContentConfig();
        /**SQL 表达式，代表您需要发起的检索操作。例如SELECT s._1 FROM COSObject s。
         这个表达式可以从 CSV 格式的对象中检索第一列内容。有关 SQL 表达式的详细介绍，
         请参见 (Select)[https://cloud.tencent.com/document/product/436/37636] 命令
        */

        config.express = "Select * from COSObject";
        /**
        表达式类型，该项为扩展项，目前只支持 SQL 表达式，仅支持 SQL 参数
        */
        config.expressionType = .SQL;

        /**
         描述待检索对象的格式
         */
        let inputS = QCloudInputSerialization();
        inputS.compressionType = .NONE;
        /**
            描述在JSON对象格式下所需的文件参数。
            */
        let inputJson = QCloudSerializationJSON.init();
        /**
            SON 文件的类型：
            DOCUMENT 表示 JSON 文件仅包含一个独立的 JSON 对象，且该对象可以被切割成多行
            LINES 表示 JSON 对象中的每一行包含了一个独立的 JSON 对象
            合法值为 DOCUMENT 、LINES
            */
        inputJson.type = .document;

        inputS.serializationJSON = inputJson;

        config.inputSerialization = inputS;

        /**
         描述检索结果的输出格式
         */
        let outputS = QCloudOutputSerialization.init();

        let outputJson = QCloudSerializationJSON.init();
        /**
            将输出结果中的记录分隔为不同行的字符，默认通过\n进行分隔。您可以指定任意8进制字符，
         如逗号、分号、Tab 等。该参数最多支持2个字节，即您可以输入\r\n这类格式的分隔符。默认值为\n
            */
        outputJson.outputRecordDelimiter = "\n";
        outputS.serializationJSON = outputJson;

        config.outputSerialization = outputS;
        /**
         是否需要返回查询进度 QueryProgress 信息，如果选中 COS Select 将周期性返回查询进度
         */
        let requestProgress = QCloudRequestProgress.init();
        requestProgress.enabled = "FALSE";
        config.requestProgress = requestProgress;
        request.selectObjectContentConfig = config;
        //文件在本地的存储路径
        request.downloadingURL = NSURL.fileURL(withPath: QCloudFileInSubPath("test", "2.json"));
        request.finishBlock = {(result,error) in
            if error != nil{
                print(error!)
            }else{
                print(result!);
            }
         }

        QCloudCOSXMLService.defaultCOSXML().selectObjectContent(request);
        //.cssg-snippet-body-end
    }

    // .cssg-methods-pragma

    func testSelectObject() {
        // 检索对象内容
        self.selectObject();
        // .cssg-methods-pragma
    }
}
