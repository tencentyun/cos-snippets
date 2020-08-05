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
    public class BucketCORSModel {

      private CosXml cosXml;

      BucketCORSModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetConnectionTimeoutMs(60000)  //设置连接超时时间，单位毫秒，默认45000ms
          .SetReadWriteTimeoutMs(40000)  //设置读写超时时间，单位毫秒，默认45000ms
          .IsHttps(true)  //设置默认 HTTPS 请求
          .SetAppid("1250000000") //设置腾讯云账户的账户标识 APPID
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .Build();
        
        string secretId = "COS_SECRETID";   //云 API 密钥 SecretId
        string secretKey = "COS_SECRETKEY"; //云 API 密钥 SecretKey
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 设置存储桶跨域规则
      public void PutBucketCors()
      {
        //.cssg-snippet-body-start:[put-bucket-cors]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          PutBucketCORSRequest request = new PutBucketCORSRequest(bucket);
          //设置签名有效时长
          request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);
          //设置跨域访问配置 CORS
          COSXML.Model.Tag.CORSConfiguration.CORSRule corsRule = 
            new COSXML.Model.Tag.CORSConfiguration.CORSRule();
          corsRule.id = "corsconfigureId";
          corsRule.maxAgeSeconds = 6000;
          corsRule.allowedOrigin = "http://cloud.tencent.com";
        
          corsRule.allowedMethods = new List<string>();
          corsRule.allowedMethods.Add("PUT");
        
          corsRule.allowedHeaders = new List<string>();
          corsRule.allowedHeaders.Add("Host");
        
          corsRule.exposeHeaders = new List<string>();
          corsRule.exposeHeaders.Add("x-cos-meta-x1");
        
          request.SetCORSRule(corsRule);
        
          //执行请求
          PutBucketCORSResult result = cosXml.PutBucketCORS(request);
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

      /// 获取存储桶跨域规则
      public void GetBucketCors()
      {
        //.cssg-snippet-body-start:[get-bucket-cors]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketCORSRequest request = new GetBucketCORSRequest(bucket);
          //设置签名有效时长
          request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);
          //执行请求
          GetBucketCORSResult result = cosXml.GetBucketCORS(request);
          //存储桶的 CORS 配置信息
          CORSConfiguration conf = result.corsConfiguration;
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

      /// 实现 Object 跨域访问配置的预请求
      public void OptionObject()
      {
        //.cssg-snippet-body-start:[option-object]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string origin = "http://cloud.tencent.com";
          string accessMthod = "PUT";
          OptionObjectRequest request = new OptionObjectRequest(bucket, key, origin, accessMthod);
          //设置签名有效时长
          request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);
          //执行请求
          OptionObjectResult result = cosXml.OptionObject(request);
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

      /// 删除存储桶跨域规则
      public void DeleteBucketCors()
      {
        //.cssg-snippet-body-start:[delete-bucket-cors]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          DeleteBucketCORSRequest request = new DeleteBucketCORSRequest(bucket);
          //设置签名有效时长
          request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);
          //执行请求
          DeleteBucketCORSResult result = cosXml.DeleteBucketCORS(request);
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
        BucketCORSModel m = new BucketCORSModel();

        /// 设置存储桶跨域规则
        m.PutBucketCors();
        /// 获取存储桶跨域规则
        m.GetBucketCors();
        /// 实现 Object 跨域访问配置的预请求
        m.OptionObject();
        /// 删除存储桶跨域规则
        m.DeleteBucketCors();
        // .cssg-methods-pragma
      }
    }
}