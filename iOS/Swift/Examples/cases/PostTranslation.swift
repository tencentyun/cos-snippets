import XCTest
import QCloudCOSXML

class PostTranslationDemo: XCTestCase,QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate{

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

	func testPostTranslation() {
			let request : QCloudPostTranslationRequest = QCloudPostTranslationRequest();
		request.bucket = "sample-1250000000";
		request.regionName = "COS_REGIONNAME";
		let postTranslation : QCloudPostTranslation = QCloudPostTranslation();
		// 创建任务的 Tag：Translation;是否必传：是
		request.input.tag = "";
		// 待操作的对象信息;是否必传：是
		let input : QCloudPostTranslationInput = QCloudPostTranslationInput();
		// 源文档文件名单文件（docx/xlsx/html/markdown/txt）：不超过800万字符有页数的（pdf/pptx）：不超过300页文本文件（txt）：不超过10MB二进制文件（pdf/docx/pptx/xlsx）：不超过60MB图片文件（jpg/jpeg/png/webp）：不超过10MB;是否必传：是
        request.input.input.object = "";
		// 文档语言类型zh：简体中文zh-hk：繁体中文zh-tw：繁体中文zh-tr：繁体中文en：英语ar：阿拉伯语de：德语es：西班牙语fr：法语id：印尼语it：意大利语ja：日语pt：葡萄牙语ru：俄语ko：韩语km：高棉语lo：老挝语;是否必传：是
        request.input.input.lang = "";
		// 文档类型pdfdocxpptxxlsxtxtxmlhtml：只能翻译 HTML 里的文本节点，需要通过 JS 动态加载的不进行翻译markdownjpgjpegpngwebp;是否必传：是
        request.input.input.type = "";
		// 操作规则;是否必传：是
		let operation : QCloudPostTranslationOperation = QCloudPostTranslationOperation();
		// 翻译参数;是否必传：是
		let translation : QCloudPostTranslationTranslation = QCloudPostTranslationTranslation();
		// 目标语言类型源语言类型为 zh/zh-hk/zh-tw/zh-tr 时支持：en、ar、de、es、fr、id、it、ja、it、ru、ko、km、lo、pt源语言类型为 en 时支持：zh、zh-hk、zh-tw、zh-tr、ar、de、es、fr、id、it、ja、it、ru、ko、km、lo、pt其他类型时支持：zh、zh-hk、zh-tw、zh-tr、en;是否必传：是
        request.input.operation.translation.lang = "";
		// 文档类型，源文件类型与目标文件类型映射关系如下：docx：docxpptx：pptxxlsx：xlsxtxt：txtxml：xmlhtml：htmlmarkdown：markdownpdf：pdf、docxpng：txtjpg：txtjpeg：txtwebp：txt;是否必传：是
        request.input.operation.translation.type = "";
		// 结果输出地址，当NoNeedOutput为true时非必选;是否必传：否
		let output : QCloudPostTranslationOutput = QCloudPostTranslationOutput();
		// 存储桶的地域;是否必传：是
        request.input.operation.output.region = "";
		// 存储结果的存储桶;是否必传：是
        request.input.operation.output.bucket = "";
		// 输出结果的文件名;是否必传：是
        request.input.operation.output.object = "";
		request.finishBlock = { result, error in
			// result：QCloudPostTranslationResponse 包含所有的响应；
			// 具体查看代码注释或api文档：https://cloud.tencent.com/document/product/460/84799
		};
		QCloudCOSXMLService.defaultCOSXML().postTranslation(request);
	
	}

}
