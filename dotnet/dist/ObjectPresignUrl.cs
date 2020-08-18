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
    public class ObjectPresignUrlModel {

      private CosXml cosXml;

      ObjectPresignUrlModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .Build();
        
        string secretId = "COS_SECRETID";   //云 API 密钥 SecretId
        string secretKey = "COS_SECRETKEY"; //云 API 密钥 SecretKey
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 获取预签名下载链接
      public void GetPresignDownloadUrl()
      {
        //.cssg-snippet-body-start:[get-presign-download-url]
        try
        {
          PreSignatureStruct preSignatureStruct = new PreSignatureStruct();
          preSignatureStruct.appid = "1250000000";//腾讯云账号 APPID
          preSignatureStruct.region = "COS_REGION"; //存储桶地域
          preSignatureStruct.bucket = "examplebucket-1250000000"; //存储桶
          preSignatureStruct.key = "exampleobject"; //对象键
          preSignatureStruct.httpMethod = "GET"; //HTTP 请求方法
          preSignatureStruct.isHttps = true; //生成 HTTPS 请求 URL
          preSignatureStruct.signDurationSecond = 600; //请求签名时间为600s
          preSignatureStruct.headers = null;//签名中需要校验的 header
          preSignatureStruct.queryParameters = null; //签名中需要校验的 URL 中请求参数
        
          string requestSignURL = cosXml.GenerateSignURL(preSignatureStruct); 
        
          //下载请求预签名 URL (使用永久密钥方式计算的签名 URL)
          string localDir = System.IO.Path.GetTempPath();//本地文件夹
          string localFileName = "my-local-temp-file"; //指定本地保存的文件名
          GetObjectRequest request = new GetObjectRequest(null, null, localDir, localFileName);
          //设置下载请求预签名 URL
          request.RequestURLWithSign = requestSignURL;
          //设置进度回调
          request.SetCosProgressCallback(delegate (long completed, long total)
          {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
          });
          //执行请求
          GetObjectResult result = cosXml.GetObject(request);
          //请求成功
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

      /// 获取预签名上传链接
      public void GetPresignUploadUrl()
      {
        //.cssg-snippet-body-start:[get-presign-upload-url]
        try
        {
          PreSignatureStruct preSignatureStruct = new PreSignatureStruct();
          preSignatureStruct.appid = "1250000000";//腾讯云账号 APPID
          preSignatureStruct.region = "COS_REGION"; //存储桶地域
          preSignatureStruct.bucket = "examplebucket-1250000000"; //存储桶
          preSignatureStruct.key = "exampleobject"; //对象键
          preSignatureStruct.httpMethod = "PUT"; //HTTP 请求方法
          preSignatureStruct.isHttps = true; //生成 HTTPS 请求 URL
          preSignatureStruct.signDurationSecond = 600; //请求签名时间为 600s
          preSignatureStruct.headers = null;//签名中需要校验的 header
          preSignatureStruct.queryParameters = null; //签名中需要校验的 URL 中请求参数
        
          //上传预签名 URL (使用永久密钥方式计算的签名 URL)
          string requestSignURL = cosXml.GenerateSignURL(preSignatureStruct);
        
          string srcPath = @"temp-source-file";//本地文件绝地路径
          PutObjectRequest request = new PutObjectRequest(null, null, srcPath);
          //设置上传请求预签名 URL
          request.RequestURLWithSign = requestSignURL;
          //设置进度回调
          request.SetCosProgressCallback(delegate (long completed, long total)
          {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
          });
          //执行请求
          PutObjectResult result = cosXml.PutObject(request);
          //请求成功
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

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        ObjectPresignUrlModel m = new ObjectPresignUrlModel();

        /// 获取预签名下载链接
        m.GetPresignDownloadUrl();
        /// 获取预签名上传链接
        m.GetPresignUploadUrl();
        // .cssg-methods-pragma
      }
    }
}