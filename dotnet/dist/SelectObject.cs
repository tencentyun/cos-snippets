using COSXML.Common;
using COSXML.CosException;
using COSXML.Model;
using COSXML.Model.Object;
using COSXML.Model.Tag;
using COSXML.Model.Bucket;
using COSXML.Model.Service;
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

namespace COSSnippet
{
    public class SelectObjectModel {

      private CosXml cosXml;

      SelectObjectModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 检索对象内容
      public void SelectObject()
      {
        //.cssg-snippet-body-start:[select-object]
        try
        {
            // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
            string bucket = "examplebucket-1250000000";
            string key = "exampleobject"; //对象键

            SelectObjectRequest request = new SelectObjectRequest(bucket, key);

            ObjectSelectionFormat.JSONFormat jSONFormat = new ObjectSelectionFormat.JSONFormat();
            jSONFormat.Type = "DOCUMENT";
            jSONFormat.RecordDelimiter = "\n";
            
            string outputFile = "select_local_file.json";

            request.SetExpression("Select * from COSObject")
                    .SetInputFormat(new ObjectSelectionFormat(null, jSONFormat))
                    .SetOutputFormat(new ObjectSelectionFormat(null, jSONFormat))
                    .SetCosProgressCallback(delegate (long progress, long total) {
                        Console.WriteLine("OnProgress : " + progress + "," + total);
                    })
                    .OutputToFile(outputFile)
                    ;

            SelectObjectResult selectObjectResult =  cosXml.SelectObject(request);
            Console.WriteLine(selectObjectResult.stat);
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
            Console.WriteLine("CosClientException: " + clientEx.StackTrace);
            Console.WriteLine("CosClientException: " + clientEx.Message);
        }
        catch (COSXML.CosException.CosServerException serverEx)
        {
            Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        SelectObjectModel m = new SelectObjectModel();

        /// 检索对象内容
        m.SelectObject();
        // .cssg-methods-pragma
      }
    }
}
