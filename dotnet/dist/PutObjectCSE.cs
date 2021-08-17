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
    public class PutObjectCSEModel {

      private CosXml cosXml;

      PutObjectCSEModel() {
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

      /// 使用 AES256 进行客户端加密
      public void PutObjectCseCAes()
      {
        //.cssg-snippet-body-start:[put-object-cse-c-aes]
        
        //.cssg-snippet-body-end
      }

      /// 使用 RSA 进行客户端加密
      public void PutObjectCseCRsa()
      {
        //.cssg-snippet-body-start:[put-object-cse-c-rsa]
        
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        PutObjectCSEModel m = new PutObjectCSEModel();

        /// 使用 AES256 进行客户端加密
        m.PutObjectCseCAes();
        /// 使用 RSA 进行客户端加密
        m.PutObjectCseCRsa();
        // .cssg-methods-pragma
      }
    }
}
