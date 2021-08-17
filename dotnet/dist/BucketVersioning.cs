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
    public class BucketVersioningModel {

      private CosXml cosXml;

      BucketVersioningModel() {
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

      /// 设置存储桶多版本
      public void PutBucketVersioning()
      {
        //.cssg-snippet-body-start:[put-bucket-versioning]
        string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        PutBucketVersioningRequest request = new PutBucketVersioningRequest(bucket);
        request.IsEnableVersionConfig(true); //true: 开启版本控制; false:暂停版本控制
        
        try
        {
          PutBucketVersioningResult result = cosXml.PutBucketVersioning(request);
          Console.WriteLine(result.GetResultInfo());
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
          Console.WriteLine("CosClientException: " + clientEx);
        }
        catch (COSXML.CosException.CosServerException serverEx)
        {
          Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        
        //.cssg-snippet-body-end
      }

      /// 获取存储桶多版本状态
      public void GetBucketVersioning()
      {
        //.cssg-snippet-body-start:[get-bucket-versioning]
        string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
        GetBucketVersioningRequest request = new GetBucketVersioningRequest(bucket);
        
        try
        {
          GetBucketVersioningResult result = cosXml.GetBucketVersioning(request);
          // 存储桶的生命周期配置
          VersioningConfiguration conf =  result.versioningConfiguration;
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
          Console.WriteLine("CosClientException: " + clientEx);
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
        BucketVersioningModel m = new BucketVersioningModel();

        /// 设置存储桶多版本
        m.PutBucketVersioning();
        /// 获取存储桶多版本状态
        m.GetBucketVersioning();
        // .cssg-methods-pragma
      }
    }
}
