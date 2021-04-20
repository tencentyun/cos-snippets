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

      /// 指定前缀批量删除对象
      public void DeletePrefix()
      {
        //.cssg-snippet-body-start:[delete-prefix]
        try
        {
          String nextMarker = null;

          // 循环请求直到没有下一页数据
          do
          {
            string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            string prefix = "folder1/"; //指定前缀
            GetBucketRequest listRequest = new GetBucketRequest(bucket);
            //获取 folder1/ 下的所有对象以及子目录
            listRequest.SetPrefix(prefix);
            listRequest.SetMarker(nextMarker);
            //执行列出对象请求
            GetBucketResult listResult = cosXml.GetBucket(listRequest);
            ListBucket info = listResult.listBucket;
            // 对象列表
            List<ListBucket.Contents> objects = info.contentsList;
            // 下一页的下标
            nextMarker = info.nextMarker;
            
            DeleteMultiObjectRequest deleteRequest = new DeleteMultiObjectRequest(bucket);
            //设置返回结果形式
            deleteRequest.SetDeleteQuiet(false);
            //对象列表
            List<string> deleteObjects = new List<string>();
            foreach (var content in objects)
            {
              deleteObjects.Add(content.key);
            }
            deleteRequest.SetObjectKeys(deleteObjects);
            //执行批量删除请求
            DeleteMultiObjectResult deleteResult = cosXml.DeleteMultiObjects(deleteRequest);
            //打印请求结果
            Console.WriteLine(deleteResult.GetResultInfo());
          } while (nextMarker != null);
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

        /// 指定前缀批量删除对象
        m.DeletePrefix();
        // .cssg-methods-pragma
      }
    }
}