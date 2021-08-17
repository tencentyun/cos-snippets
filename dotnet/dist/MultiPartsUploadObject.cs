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
    public class MultiPartsUploadObjectModel {

      private CosXml cosXml;
      private string uploadId;
      private string eTag;

      MultiPartsUploadObjectModel() {
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
          this.uploadId = result.initMultipartUpload.uploadId; //用于后续分块上传的 uploadId
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

      /// 列出所有未完成的分片上传任务
      public void ListMultiUpload()
      {
        //.cssg-snippet-body-start:[list-multi-upload]
        try
        {
          string bucket = "examplebucket-1250000000"; //格式：BucketName-APPID
          ListMultiUploadsRequest request = new ListMultiUploadsRequest(bucket);
          //执行请求
          ListMultiUploadsResult result = cosXml.ListMultiUploads(request);
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

      /// 上传一个分片
      public void UploadPart()
      {
        //.cssg-snippet-body-start:[upload-part]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string uploadId = "exampleUploadId"; //初始化分块上传返回的uploadId
          int partNumber = 1; //分块编号，必须从1开始递增
          string srcPath = @"temp-source-file";//本地文件绝对路径
          UploadPartRequest request = new UploadPartRequest(bucket, key, partNumber, 
            uploadId, srcPath, 0, -1);
          //设置进度回调
          request.SetCosProgressCallback(delegate (long completed, long total)
          {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
          });
          //执行请求
          UploadPartResult result = cosXml.UploadPart(request);
          //请求成功
          //获取返回分块的eTag,用于后续CompleteMultiUploads
          this.eTag = result.eTag;
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

      /// 列出已上传的分片
      public void ListParts()
      {
        //.cssg-snippet-body-start:[list-parts]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string uploadId = "exampleUploadId"; //初始化分块上传返回的uploadId
          ListPartsRequest request = new ListPartsRequest(bucket, key, uploadId);
          //执行请求
          ListPartsResult result = cosXml.ListParts(request);
          //请求成功
          //列举已上传的分块
          List<COSXML.Model.Tag.ListParts.Part> alreadyUploadParts = result.listParts.parts;
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

      /// 完成分片上传任务
      public void CompleteMultiUpload()
      {
        //.cssg-snippet-body-start:[complete-multi-upload]
        try
        {
          string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
          string key = "exampleobject"; //对象键
          string uploadId = "exampleUploadId"; //初始化分块上传返回的uploadId
          CompleteMultipartUploadRequest request = new CompleteMultipartUploadRequest(bucket, 
            key, uploadId);
          //设置已上传的parts,必须有序，按照partNumber递增
          request.SetPartNumberAndETag(1, this.eTag);
          //执行请求
          CompleteMultipartUploadResult result = cosXml.CompleteMultiUpload(request);
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
        MultiPartsUploadObjectModel m = new MultiPartsUploadObjectModel();

        /// 初始化分片上传
        m.InitMultiUpload();
        /// 列出所有未完成的分片上传任务
        m.ListMultiUpload();
        /// 上传一个分片
        m.UploadPart();
        /// 列出已上传的分片
        m.ListParts();
        /// 完成分片上传任务
        m.CompleteMultiUpload();
        // .cssg-methods-pragma
      }
    }
}
