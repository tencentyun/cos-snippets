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
    public class BucketTaggingModel {

      private CosXml cosXml;

      BucketTaggingModel() {
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

      /// 设置存储桶标签
      public void PutBucketTagging()
      {
        //.cssg-snippet-body-start:[put-bucket-tagging]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          PutBucketTaggingRequest request = new PutBucketTaggingRequest(bucket);
          string akey = "aTagKey";
          string avalue = "aTagValue";
          string bkey = "bTagKey";
          string bvalue = "bTagValue";

          request.AddTag(akey, avalue);
          request.AddTag(bkey, bvalue);
          
          //执行请求
          PutBucketTaggingResult result = cosXml.PutBucketTagging(request);
          
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

      /// 获取存储桶标签
      public void GetBucketTagging()
      {
        //.cssg-snippet-body-start:[get-bucket-tagging]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          GetBucketTaggingRequest request = new GetBucketTaggingRequest(bucket);   
          //执行请求
          GetBucketTaggingResult result = cosXml.GetBucketTagging(request);
          
          //请求成功
          Tagging tagging = result.tagging;
          Console.WriteLine(tagging);
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

      /// 删除存储桶标签
      public void DeleteBucketTagging()
      {
        //.cssg-snippet-body-start:[delete-bucket-tagging]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
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
        BucketTaggingModel m = new BucketTaggingModel();

        /// 设置存储桶标签
        m.PutBucketTagging();
        /// 获取存储桶标签
        m.GetBucketTagging();
        /// 删除存储桶标签
        m.DeleteBucketTagging();
        // .cssg-methods-pragma
      }
    }
}
