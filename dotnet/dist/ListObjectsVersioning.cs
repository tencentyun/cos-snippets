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
    public class ListObjectsVersioningModel {

      private CosXml cosXml;
      private string keyMarker;
      private string versionIdMarker;

      ListObjectsVersioningModel() {
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

      /// 获取对象多版本列表第一页数据
      public void ListObjectsVersioning()
      {
        //.cssg-snippet-body-start:[list-objects-versioning]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          ListBucketVersionsRequest request = new ListBucketVersionsRequest(bucket);
          //执行请求
          ListBucketVersionsResult result = cosXml.ListBucketVersions(request);
          //bucket的相关信息
          ListBucketVersions info = result.listBucketVersions;

          List<ListBucketVersions.Version> objects = info.objectVersionList;
          List<ListBucketVersions.CommonPrefixes> prefixes = info.commonPrefixesList;

          if (info.isTruncated) {
            // 数据被截断，记录下数据下标
            this.keyMarker = info.nextKeyMarker;
            this.versionIdMarker = info.nextVersionIdMarker;
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

      /// 获取对象多版本列表下一页数据
      public void ListObjectsVersioningNextPage()
      {
        //.cssg-snippet-body-start:[list-objects-versioning-next-page]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          ListBucketVersionsRequest request = new ListBucketVersionsRequest(bucket);

          // 上一页的数据结束下标
          request.SetKeyMarker(this.keyMarker);
          request.SetVersionIdMarker(this.versionIdMarker);

          //执行请求
          ListBucketVersionsResult result = cosXml.ListBucketVersions(request);
          ListBucketVersions info = result.listBucketVersions;

          if (info.isTruncated) {
            // 数据被截断，记录下数据下标
            this.keyMarker = info.nextKeyMarker;
            this.versionIdMarker = info.nextVersionIdMarker;
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
        ListObjectsVersioningModel m = new ListObjectsVersioningModel();

        /// 获取对象多版本列表第一页数据
        m.ListObjectsVersioning();
        /// 获取对象多版本列表下一页数据
        m.ListObjectsVersioningNextPage();
        // .cssg-methods-pragma
      }
    }
}
