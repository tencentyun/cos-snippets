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
    public class DeleteObjectModel {

      private CosXml cosXml;

      DeleteObjectModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .Build();
        
        string secretId = "COS_SECRETID";   //云 API 密钥 SecretId
        string secretKey = "COS_SECRETKEY"; //云 API 密钥 SecretKey
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 删除对象
      public void DeleteObject()
      {
        //.cssg-snippet-body-start:[delete-object]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          DeleteObjectRequest request = new DeleteObjectRequest(bucket, key);
          //执行请求
          DeleteObjectResult result = cosXml.DeleteObject(request);
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

      /// 删除多个对象
      public void DeleteMultiObject()
      {
        //.cssg-snippet-body-start:[delete-multi-object]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          DeleteMultiObjectRequest request = new DeleteMultiObjectRequest(bucket);
          //设置返回结果形式
          request.SetDeleteQuiet(false);
          //对象key
          string key = "exampleobject"; //对象键
          List<string> objects = new List<string>();
          objects.Add(key);
          request.SetObjectKeys(objects);
          //执行请求
          DeleteMultiObjectResult result = cosXml.DeleteMultiObjects(request);
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
        DeleteObjectModel m = new DeleteObjectModel();

        /// 删除对象
        m.DeleteObject();
        /// 删除多个对象
        m.DeleteMultiObject();
        // .cssg-methods-pragma
      }
    }
}