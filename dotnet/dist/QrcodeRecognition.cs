using COSXML.Common;
using COSXML.CosException;
using COSXML.Model;
using COSXML.Model.Object;
using COSXML.Model.Tag;
using COSXML.Model.Bucket;
using COSXML.Model.Service;
using COSXML.Model.CI;
using COSXML.Utils;
using COSXML.Auth;
using COSXML.Transfer;
using System;
using COSXML;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace COSSnippet
{
    public class QrcodeRecognitionModel {

      private CosXml cosXml;

      QrcodeRecognitionModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .Build();
        
        string secretId = "SECRET_ID";   //云 API 密钥 SecretId
        string secretKey = "SECRET_KEY"; //云 API 密钥 SecretKey
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 上传时进行二维码识别
      public void UploadWithQRcodeRecognition()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[upload-with-QRcode-recognition]
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);

        JObject o = new JObject();
        // 不返回原图
        o["is_pic_info"] = 1;
        JArray rules = new JArray();
        JObject rule = new JObject();
        rule["bucket"] = bucket;
        rule["fileid"] = "qrcode.jpg";
        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/37513
        rule["rule"] = "QRcode/cover/<mode>";
        rules.Add(rule);
        o["rules"] = rules;

        string ruleString = o.ToString(Formatting.None);
        request.SetRequestHeader("Pic-Operations", ruleString);
        //执行请求
        PutObjectResult result = cosXml.PutObject(request);
        //.cssg-snippet-body-end
      }

      /// 下载时进行二维码识别
      public void DownloadWithQrcodeRecognition()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        //.cssg-snippet-body-start:[download-with-qrcode-recognition]
        //二维码覆盖功能，将对识别出的二维码覆盖上马赛克。取值为0或1。0表示不开启二维码覆盖，1表示开启二维码覆盖，默认值0
        QRCodeRecognitionRequest request = new QRCodeRecognitionRequest(bucket, key, 0);

        QRCodeRecognitionResult result = cosXml.QRCodeRecognition(request);
        
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        QrcodeRecognitionModel m = new QrcodeRecognitionModel();

        /// 上传时进行二维码识别
        m.UploadWithQRcodeRecognition();
        /// 下载时进行二维码识别
        m.DownloadWithQrcodeRecognition();
        // .cssg-methods-pragma
      }
    }
}
