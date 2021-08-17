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
    public class BucketDomainModel {

      private CosXml cosXml;

      BucketDomainModel() {
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

      /// 设置存储桶自定义域名
      public void PutBucketDomain()
      {
        //.cssg-snippet-body-start:[put-bucket-domain]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          
          DomainConfiguration domain = new DomainConfiguration();
          domain.rule = new DomainConfiguration.DomainRule();
          domain.rule.Name = "www.qq.com";
          domain.rule.Status = "ENABLED";
          domain.rule.Type = "WEBSITE";
          
          PutBucketDomainRequest request = new PutBucketDomainRequest(bucket, domain);   
          //执行请求
          PutBucketDomainResult result = cosXml.PutBucketDomain(request);
          
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

      /// 获取存储桶自定义域名
      public void GetBucketDomain()
      {
        //.cssg-snippet-body-start:[get-bucket-domain]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketDomainRequest request = new GetBucketDomainRequest(bucket);   
          //执行请求
          GetBucketDomainResult result = cosXml.GetBucketDomain(request);
          
          //请求成功
          Console.WriteLine(result.domainConfiguration);
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

      /// 删除存储桶自定义域名
      public void DeleteBucketDomain()
      {
        //.cssg-snippet-body-start:[delete-bucket-domain]
        
        //.cssg-snippet-body-end
      }


      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        BucketDomainModel m = new BucketDomainModel();

        /// 设置存储桶自定义域名
        m.PutBucketDomain();
        /// 获取存储桶自定义域名
        m.GetBucketDomain();

        /// 删除存储桶自定义域名
        m.DeleteBucketDomain();
        // .cssg-methods-pragma
      }
    }
}
