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
    public class ModifyObjectPropertyModel {

      private CosXml cosXml;

      ModifyObjectPropertyModel() {
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

      /// 修改对象元数据
      public void ModifyObjectMetadata()
      {
        //.cssg-snippet-body-start:[modify-object-metadata]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string appId = "1250000000"; //账号 appid
          string region = "COS_REGION"; //源对象的存储桶所在的地域
          //构造对象属性
          CopySourceStruct copySource = new CopySourceStruct(appId, bucket, 
            region, key);
        
          CopyObjectRequest request = new CopyObjectRequest(bucket, key);
          //设置拷贝源
          request.SetCopySource(copySource);
          //设置是否拷贝还是更新,此处是拷贝
          request.SetCopyMetaDataDirective(COSXML.Common.CosMetaDataDirective.Replaced);
          // 替换元数据
          request.SetRequestHeader("Content-Disposition", "attachment; filename=example.jpg");
          request.SetRequestHeader("Content-Type", "image/png");
          //执行请求
          CopyObjectResult result = cosXml.CopyObject(request);
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

      /// 修改对象存储类型
      public void ModifyObjectStorageClass()
      {
        //.cssg-snippet-body-start:[modify-object-storage-class]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string appId = "1250000000"; //账号 appid
          string region = "COS_REGION"; //源对象的存储桶所在的地域
          //构造对象属性
          CopySourceStruct copySource = new CopySourceStruct(appId, bucket, 
            region, key);
        
          CopyObjectRequest request = new CopyObjectRequest(bucket, key);
          //设置拷贝源
          request.SetCopySource(copySource);
          //设置是否拷贝还是更新,此处是拷贝
          request.SetCopyMetaDataDirective(COSXML.Common.CosMetaDataDirective.Replaced);
          // 修改为归档存储
          request.SetCosStorageClass("ARCHIVE");
          //执行请求
          CopyObjectResult result = cosXml.CopyObject(request);
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

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        ModifyObjectPropertyModel m = new ModifyObjectPropertyModel();

        /// 修改对象元数据
        m.ModifyObjectMetadata();
        /// 修改对象存储类型
        m.ModifyObjectStorageClass();
        // .cssg-methods-pragma
      }
    }
}
