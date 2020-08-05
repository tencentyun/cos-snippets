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
          PutBucketDomainResult result = cosXml.putBucketDomain(request);
          
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
          GetBucketDomainResult result = cosXml.getBucketDomain(request);
          
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

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        BucketDomainModel m = new BucketDomainModel();

        /// 设置存储桶自定义域名
        m.PutBucketDomain();
        /// 获取存储桶自定义域名
        m.GetBucketDomain();
        // .cssg-methods-pragma
      }
    }
}