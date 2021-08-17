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
    public class BucketWebsiteModel {

      private CosXml cosXml;

      BucketWebsiteModel() {
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

      /// 设置存储桶静态网站
      public void PutBucketWebsite()
      {
        //.cssg-snippet-body-start:[put-bucket-website]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          PutBucketWebsiteRequest putRequest = new PutBucketWebsiteRequest(bucket);
          putRequest.SetIndexDocument("index.html");
          putRequest.SetErrorDocument("eroror.html");
          putRequest.SetRedirectAllRequestTo("index.html");
          PutBucketWebsiteResult putResult = cosXml.PutBucketWebsite(putRequest);
          
          //请求成功
          Console.WriteLine(putResult.GetResultInfo());
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

      /// 获取存储桶静态网站
      public void GetBucketWebsite()
      {
        //.cssg-snippet-body-start:[get-bucket-website]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          DeleteBucketTaggingRequest request = new DeleteBucketTaggingRequest(bucket);   
          //执行请求
          DeleteBucketTaggingResult result = cosXml.DeleteBucketTagging(request);
          
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

      /// 删除存储桶静态网站
      public void DeleteBucketWebsite()
      {
        //.cssg-snippet-body-start:[delete-bucket-website]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          DeleteBucketTaggingRequest request = new DeleteBucketTaggingRequest(bucket);   
          //执行请求
          DeleteBucketTaggingResult result = cosXml.DeleteBucketTagging(request);
          
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
        BucketWebsiteModel m = new BucketWebsiteModel();

        /// 设置存储桶静态网站
        m.PutBucketWebsite();
        /// 获取存储桶静态网站
        m.GetBucketWebsite();
        /// 删除存储桶静态网站
        m.DeleteBucketWebsite();
        // .cssg-methods-pragma
      }
    }
}
