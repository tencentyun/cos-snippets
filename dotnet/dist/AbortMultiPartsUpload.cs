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
    public class AbortMultiPartsUploadModel {

      private CosXml cosXml;

      private string uploadId;

      AbortMultiPartsUploadModel() {
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

      /// 初始化分片上传
      public void InitMultiUpload()
      {
        //.cssg-snippet-body-start:[init-multi-upload]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          InitMultipartUploadRequest request = new InitMultipartUploadRequest(bucket, key);
          //执行请求
          InitMultipartUploadResult result = cosXml.InitMultipartUpload(request);
          //请求成功
          //用于后续分块上传的 uploadId
          this.uploadId = result.initMultipartUpload.uploadId;
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

      /// 终止分片上传任务
      public void AbortMultiUpload()
      {
        //.cssg-snippet-body-start:[abort-multi-upload]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string uploadId = "exampleUploadId"; //初始化分块上传返回的uploadId
          AbortMultipartUploadRequest request = new AbortMultipartUploadRequest(bucket, key, uploadId);
          //执行请求
          AbortMultipartUploadResult result = cosXml.AbortMultiUpload(request);
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
        AbortMultiPartsUploadModel m = new AbortMultiPartsUploadModel();

        /// 初始化分片上传
        m.InitMultiUpload();
        /// 终止分片上传任务
        m.AbortMultiUpload();
        // .cssg-methods-pragma
      }
    }
}
