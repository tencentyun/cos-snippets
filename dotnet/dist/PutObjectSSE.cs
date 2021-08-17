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
    public class PutObjectSSEModel {

      private CosXml cosXml;

      PutObjectSSEModel() {
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

      /// 使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
      public void PutObjectSse()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[put-object-sse]
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);
        request.SetCosServerSideEncryption();
        //.cssg-snippet-body-end
      }

      /// 使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
      public void PutObjectSseC()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[put-object-sse-c]   
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);
        request.SetCosServerSideEncryptionWithCustomerKey("Your Secret Key");
        //.cssg-snippet-body-end
      }

      /// 使用 KMS 托管加密密钥的服务端加密（SSE-KMS）保护数据
      public void PutObjectSseKms()
      {
        //.cssg-snippet-body-start:[put-object-sse-kms]
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[put-object-sse-c]   
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);
        request.SetCosServerSideEncryptionWithKMS("KMS Custem Key ID", "Context Json");
        //.cssg-snippet-body-end
      }


      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        PutObjectSSEModel m = new PutObjectSSEModel();

        /// 使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
        m.PutObjectSse();
        /// 使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
        m.PutObjectSseC();

        /// 使用 KMS 托管加密密钥的服务端加密（SSE-KMS）保护数据
        m.PutObjectSseKms();
        // .cssg-methods-pragma
      }
    }
}
