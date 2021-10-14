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
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
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
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          //请求域名为 your.domain.com
          .SetHost("your.domain.com") //自定义域名
          .Build();
        //.cssg-snippet-body-end
      }

      /// 设置全球加速域名
      public void SetAccelerateDomain()
      {
        //.cssg-snippet-body-start:[set-accelerate-domain]
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetEndpointSuffix("cos.accelerate.myqcloud.com")
          .Build();
        //.cssg-snippet-body-end
      }

      /// 设置请求域名后缀
      public void SetEndpointSuffix()
      {
        //.cssg-snippet-body-start:[set-endpoint-suffix]
        CosXmlConfig config = new CosXmlConfig.Builder()
          //请求域名为 [bucketName-APPID].your.domain.com
          .SetEndpointSuffix("your.domain.com")
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
