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
    public class GetServiceModel {

      private CosXml cosXml;

      GetServiceModel() {
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

      /// 获取存储桶列表
      public void GetService()
      {
        //.cssg-snippet-body-start:[get-service]
        try
        {
          GetServiceRequest request = new GetServiceRequest();
          //执行请求
          GetServiceResult result = cosXml.GetService(request);
          //得到所有的 buckets
          List<ListAllMyBuckets.Bucket> allBuckets = result.listAllMyBuckets.buckets;
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

      /// 获取地域的存储桶列表
      public void GetRegionalService()
      {
        //.cssg-snippet-body-start:[get-regional-service]
        try
        {
          GetServiceRequest request = new GetServiceRequest();
          string region = "ap-guangzhou";
          request.host = $"cos.{region}.myqcloud.com";
          //执行请求
          GetServiceResult result = cosXml.GetService(request);
          //得到所有的 buckets
          List<ListAllMyBuckets.Bucket> allBuckets = result.listAllMyBuckets.buckets;
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

      /// 计算签名
      public void GetAuthorization()
      {
        //.cssg-snippet-body-start:[get-authorization]
        
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        GetServiceModel m = new GetServiceModel();

        /// 获取存储桶列表
        m.GetService();
        /// 获取地域的存储桶列表
        m.GetRegionalService();
        /// 计算签名
        m.GetAuthorization();
        // .cssg-methods-pragma
      }
    }
}