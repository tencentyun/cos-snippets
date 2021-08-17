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
    public class ListObjectsModel {

      private CosXml cosXml;
      private string nextMarker;

      ListObjectsModel() {
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

      /// 获取对象列表
      public void GetBucket()
      {
        //.cssg-snippet-body-start:[get-bucket]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketRequest request = new GetBucketRequest(bucket);
          //执行请求
          GetBucketResult result = cosXml.GetBucket(request);
          //bucket的相关信息
          ListBucket info = result.listBucket;
          if (info.isTruncated) {
            // 数据被截断，记录下数据下标
            this.nextMarker = info.nextMarker;
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

      /// 获取第二页对象列表
      public void GetBucketNextPage()
      {
        //.cssg-snippet-body-start:[get-bucket-next-page]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketRequest request = new GetBucketRequest(bucket);
          //上一次拉取数据的下标
          request.SetMarker(this.nextMarker);
          //执行请求
          GetBucketResult result = cosXml.GetBucket(request);
          //bucket的相关信息
          ListBucket info = result.listBucket;
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

      /// 获取对象列表与子目录
      public void GetBucketWithDelimiter()
      {
        //.cssg-snippet-body-start:[get-bucket-with-delimiter]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          GetBucketRequest request = new GetBucketRequest(bucket);
          //获取 a/ 下的对象以及子目录
          request.SetPrefix("a/");
          request.SetDelimiter("/");
          //执行请求
          GetBucketResult result = cosXml.GetBucket(request);
          //bucket的相关信息
          ListBucket info = result.listBucket;
          // 对象列表
          List<ListBucket.Contents> objects = info.contentsList;
          // 子目录列表
          List<ListBucket.CommonPrefixes> subDirs = info.commonPrefixesList;
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
        ListObjectsModel m = new ListObjectsModel();

        /// 获取对象列表
        m.GetBucket();
        /// 获取第二页对象列表
        m.GetBucketNextPage();
        /// 获取对象列表与子目录
        m.GetBucketWithDelimiter();
        // .cssg-methods-pragma
      }
    }
}
