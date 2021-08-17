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
    public class BucketLifecycleModel {

      private CosXml cosXml;

      BucketLifecycleModel() {
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

      /// 设置存储桶生命周期
      public void PutBucketLifecycle()
      {
        //.cssg-snippet-body-start:[put-bucket-lifecycle]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          PutBucketLifecycleRequest request = new PutBucketLifecycleRequest(bucket);
          //设置 lifecycle
          LifecycleConfiguration.Rule rule = new LifecycleConfiguration.Rule();
          rule.id = "lfiecycleConfigureId";
          rule.status = "Enabled"; //Enabled，Disabled
        
          rule.filter = new COSXML.Model.Tag.LifecycleConfiguration.Filter();
          rule.filter.prefix = "2/";
        
          //指定分片过期删除操作
          rule.abortIncompleteMultiUpload = new LifecycleConfiguration.AbortIncompleteMultiUpload();
          rule.abortIncompleteMultiUpload.daysAfterInitiation = 2;
        
          request.SetRule(rule);
        
          //执行请求
          PutBucketLifecycleResult result = cosXml.PutBucketLifecycle(request);
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

      /// 获取存储桶生命周期
      public void GetBucketLifecycle()
      {
        //.cssg-snippet-body-start:[get-bucket-lifecycle]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketLifecycleRequest request = new GetBucketLifecycleRequest(bucket);
          //执行请求
          GetBucketLifecycleResult result = cosXml.GetBucketLifecycle(request);
          //存储桶的生命周期配置
          LifecycleConfiguration conf = result.lifecycleConfiguration;
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

      /// 删除存储桶生命周期
      public void DeleteBucketLifecycle()
      {
        //.cssg-snippet-body-start:[delete-bucket-lifecycle]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          DeleteBucketLifecycleRequest request = new DeleteBucketLifecycleRequest(bucket);
          //执行请求
          DeleteBucketLifecycleResult result = cosXml.DeleteBucketLifecycle(request);
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
        BucketLifecycleModel m = new BucketLifecycleModel();

        /// 设置存储桶生命周期
        m.PutBucketLifecycle();
        /// 获取存储桶生命周期
        m.GetBucketLifecycle();
        /// 删除存储桶生命周期
        m.DeleteBucketLifecycle();
        // .cssg-methods-pragma
      }
    }
}
