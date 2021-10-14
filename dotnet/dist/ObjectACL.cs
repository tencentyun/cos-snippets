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
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
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
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
          PutObjectACLRequest request = new PutObjectACLRequest(bucket, key);
          //设置私有读写权限 
          request.SetCosACL(CosACL.Private);
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
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
          GetObjectACLRequest request = new GetObjectACLRequest(bucket, key);
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
