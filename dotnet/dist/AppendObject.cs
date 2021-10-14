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
using System.Net;

using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using COSXML.Log;
using System.Net.Cache;
using System.Collections;


namespace COSSnippet
{
    public class AppendObjectModel {

      private static CosXml cosXml;
      private static int count = 0;

      AppendObjectModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 追加上传对象
      public void AppendObject()
      {
        //.cssg-snippet-body-start:[Append-object]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
         string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
	        string srcPath = @"temp-source-file";//本地文件绝对路径
       
          //首次append上传,追加位置传0,创建一个appendable对象 
          long next_append_position = 0;
          AppendObjectRequest request = new AppendObjectRequest(bucket, key, srcPath, next_append_position);
          //设置进度回调
          request.SetCosProgressCallback(delegate (long completed, long total)
          {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
          });
          AppendObjectResult result = cosXml.AppendObject(request);
          //获取下次追加位置
          next_append_position = result.nextAppendPosition;
          Console.WriteLine(result.GetResultInfo());
          
          //执行追加,传入上次获取的对象末尾
          request = new AppendObjectRequest(bucket, key, srcPath, next_append_position);
          request.SetCosProgressCallback(delegate (long completed, long total)
          {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
          });
          result = cosXml.AppendObject(request);
          Console.WriteLine(result.GetResultInfo());
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
          //请求失败
          Console.WriteLine("CosClientException: " + clientEx);
        }
        catch (COSXML.CosException.CosServerException serverEx)
        {
          //请求失败
          Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragm

      static void Main(string[] args)
      {
        AppendObjectModel m = new AppendObjectModel();
        m.AppendObject();
      }
    }
}
