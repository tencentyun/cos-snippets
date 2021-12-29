using COSXML.Model;
using COSXML.Model.Object;
using COSXML.Model.Tag;
using COSXML.Auth;
using System;
using COSXML;
using System.Linq;

namespace COSSnippet
{
    public class ObjectTaggingModel {

      private CosXml cosXml;

      ObjectTaggingModel() {
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

      /// 设置对象标签, 此接口从 5.4.25 版本开始支持
      public void PutObjectTagging()
      {
        //.cssg-snippet-body-start:[put-object-tagging]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
          PutObjectTaggingRequest request = new PutObjectTaggingRequest(bucket, key);
          // 增加标签键值对 
          request.AddTag("tag1", "value1");
          //执行请求
          PutObjectTaggingResult result = cosXml.PutObjectTagging(request);
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
        
      }

      /// 获取对象标签, 此接口从 5.4.25 版本开始支持
      public void GetObjectTagging()
      {
        //.cssg-snippet-body-start:[get-object-tagging]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
          GetObjectTaggingRequest request = new GetObjectTaggingRequest(bucket, key);
          // 执行请求
          GetObjectTaggingResult result = cosXml.GetObjectTagging(request);
          // 请求成功
          Console.WriteLine(result.GetResultInfo());
          // 遍历输出Tagging列表
          for (int i = 0; i < result.tagging.tagSet.tags.Count; i++) {
            Console.WriteLine(result.tagging.tagSet.tags[i].key);
            Console.WriteLine(result.tagging.tagSet.tags[i].value);
          }
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

      /// 删除对象标签, 此接口从 5.4.25 版本开始支持
      public void DeleteObjectTagging()
      {
        //.cssg-snippet-body-start:[delete-object-tagging]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
          DeleteObjectTaggingRequest request = new DeleteObjectTaggingRequest(bucket, key);
          // 执行请求
          DeleteObjectTaggingResult result = cosXml.DeleteObjectTagging(request);
          // 请求成功
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
        ObjectTaggingModel m = new ObjectTaggingModel();

        /// 设置对象标签
        m.PutObjectTagging();
        /// 获取对象标签
        m.GetObjectTagging();
        /// 删除对象标签
        m.DeleteObjectTagging();
        // .cssg-methods-pragma
      }
    }
}
