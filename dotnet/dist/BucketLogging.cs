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
    public class BucketLoggingModel {

      private CosXml cosXml;

      BucketLoggingModel() {
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

      /// 开启存储桶日志服务
      public void PutBucketLogging()
      {
        //.cssg-snippet-body-start:[put-bucket-logging]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          PutBucketLoggingRequest request = new PutBucketLoggingRequest(bucket);
          // 设置保存日志的目标路径
          request.SetTarget("targetbucket-1250000000", "logs/");
          //执行请求
          PutBucketLoggingResult result = cosXml.putBucketLogging(request);
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

      /// 获取存储桶日志服务
      public void GetBucketLogging()
      {
        //.cssg-snippet-body-start:[get-bucket-logging]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketLoggingRequest request = new GetBucketLoggingRequest(bucket);
          //执行请求
          GetBucketLoggingResult getResult = cosXml.getBucketLogging(request);
          //请求成功
          BucketLoggingStatus status = getResult.bucketLoggingStatus;
          if (status != null && status.loggingEnabled != null) {
            string targetBucket = status.loggingEnabled.targetBucket;
            string targetPrefix = status.loggingEnabled.targetPrefix;
          }
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
        BucketLoggingModel m = new BucketLoggingModel();

        /// 开启存储桶日志服务
        m.PutBucketLogging();
        /// 获取存储桶日志服务
        m.GetBucketLogging();
        // .cssg-methods-pragma
      }
    }
}