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
    public class SetCustomDomainModel {

      private CosXml cosXml;

      SetCustomDomainModel() {
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

      /// 设置默认加速域名
      public void SetCdnDomain()
      {
        //.cssg-snippet-body-start:[set-cdn-domain]
        //.cssg-snippet-body-end
      }

      /// 设置自定义加速域名
      public void SetCdnCustomDomain()
      {
        //.cssg-snippet-body-start:[set-cdn-custom-domain]
        //.cssg-snippet-body-end
      }

      /// 设置自定义域名
      public void SetCustomDomain()
      {
        //.cssg-snippet-body-start:[set-custom-domain]
        CosXmlConfig config = new CosXmlConfig.Builder()
          .IsHttps(true)  //设置默认 HTTPS 请求
          .SetAppid("1250000000") //设置腾讯云账户的账户标识 APPID
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          //请求域名为 your.domain.com
          .setHost("your.domain.com") //自定义域名
          .Build();
        //.cssg-snippet-body-end
      }

      /// 设置全球加速域名
      public void SetAccelerateDomain()
      {
        //.cssg-snippet-body-start:[set-accelerate-domain]
        CosXmlConfig config = new CosXmlConfig.Builder()
          .IsHttps(true)  //设置默认 HTTPS 请求
          .SetAppid("1250000000") //设置腾讯云账户的账户标识 APPID
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .setEndpointSuffix("cos.accelerate.myqcloud.com")
          .Build();
        //.cssg-snippet-body-end
      }

      /// 设置请求域名后缀
      public void SetEndpointSuffix()
      {
        //.cssg-snippet-body-start:[set-endpoint-suffix]
        CosXmlConfig config = new CosXmlConfig.Builder()
          .IsHttps(true)  //设置默认 HTTPS 请求
          .SetAppid("1250000000") //设置腾讯云账户的账户标识 APPID
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          //请求域名为 [bucketName-APPID].your.domain.com
          .setEndpointSuffix("your.domain.com")
          .Build();
        //.cssg-snippet-body-end
      }


      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        SetCustomDomainModel m = new SetCustomDomainModel();

        /// 设置默认加速域名
        m.SetCdnDomain();
        /// 设置自定义加速域名
        m.SetCdnCustomDomain();
        /// 设置自定义域名
        m.SetCustomDomain();
        /// 设置全球加速域名
        m.SetAccelerateDomain();

        /// 设置请求域名后缀
        m.SetEndpointSuffix();
        // .cssg-methods-pragma
      }
    }
}