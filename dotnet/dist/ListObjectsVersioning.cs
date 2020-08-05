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

      ListObjectsVersioningModel() {
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

      /// 获取对象多版本列表第一页数据
      public void ListObjectsVersioning()
      {
        //.cssg-snippet-body-start:[list-objects-versioning]
        
        //.cssg-snippet-body-end
      }

      /// 获取对象多版本列表下一页数据
      public void ListObjectsVersioningNextPage()
      {
        //.cssg-snippet-body-start:[list-objects-versioning-next-page]
        
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