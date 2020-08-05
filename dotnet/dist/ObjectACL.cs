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
    public class ObjectACLModel {

      private CosXml cosXml;

      ObjectACLModel() {
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

      /// 设置对象 ACL
      public void PutObjectAcl()
      {
        //.cssg-snippet-body-start:[put-object-acl]
        // 因为存储桶 ACL 最多1000条，为避免 ACL 达到上限，
        // 非必须情况不建议给对象单独设置 ACL(对象默认继承 bucket 权限).
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          PutObjectACLRequest request = new PutObjectACLRequest(bucket, key);
          //设置签名有效时长
          request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);
          //设置私有读写权限 
          request.SetCosACL(CosACL.PRIVATE);
          //授予1131975903账号读权限 
          COSXML.Model.Tag.GrantAccount readAccount = new COSXML.Model.Tag.GrantAccount();
          readAccount.AddGrantAccount("1131975903", "1131975903");
          request.SetXCosGrantRead(readAccount);
          //执行请求
          PutObjectACLResult result = cosXml.PutObjectACL(request);
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

      /// 获取对象 ACL
      public void GetObjectAcl()
      {
        //.cssg-snippet-body-start:[get-object-acl]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          GetObjectACLRequest request = new GetObjectACLRequest(bucket, key);
          //设置签名有效时长
          request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);
          //执行请求
          GetObjectACLResult result = cosXml.GetObjectACL(request);
          //对象的 ACL 信息
          AccessControlPolicy acl = result.accessControlPolicy;
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
        ObjectACLModel m = new ObjectACLModel();

        /// 设置对象 ACL
        m.PutObjectAcl();
        /// 获取对象 ACL
        m.GetObjectAcl();
        // .cssg-methods-pragma
      }
    }
}