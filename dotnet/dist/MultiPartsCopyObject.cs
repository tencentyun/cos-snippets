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
    public class MultiPartsCopyObjectModel {

      private CosXml cosXml;
      private string uploadId;
      private string eTag;

      MultiPartsCopyObjectModel() {
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

      /// 初始化分片上传
      public void InitMultiUpload()
      {
        //.cssg-snippet-body-start:[init-multi-upload]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
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

      /// 拷贝一个分片
      public void UploadPartCopy()
      {
        //.cssg-snippet-body-start:[upload-part-copy]
        try
        {
          string sourceAppid = "1250000000"; //账号 appid
          string sourceBucket = "sourcebucket-1250000000"; //"源对象所在的存储桶
          string sourceRegion = "COS_REGION"; //源对象的存储桶所在的地域
          string sourceKey = "sourceObject"; //源对象键
          //构造源对象属性
          COSXML.Model.Tag.CopySourceStruct copySource = new CopySourceStruct(sourceAppid, 
            sourceBucket, sourceRegion, sourceKey);
        
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string key = "exampleobject"; //对象键
          string uploadId = this.uploadId; //初始化分块上传返回的uploadId
          int partNumber = 1; //分块编号，必须从1开始递增
          UploadPartCopyRequest request = new UploadPartCopyRequest(bucket, key, 
            partNumber, uploadId);
          //设置拷贝源
          request.SetCopySource(copySource);
          //设置复制分块（指定块的范围，如 0 ~ 1M）
          request.SetCopyRange(0, 1024 * 1024);
          //执行请求
          UploadPartCopyResult result = cosXml.PartCopy(request);
          //请求成功
          //获取返回分块的eTag,用于后续CompleteMultiUploads
          this.eTag = result.copyPart.eTag;
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

      /// 完成分片拷贝任务
      public void CompleteMultiUpload()
      {
        //.cssg-snippet-body-start:[complete-multi-upload]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
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
        MultiPartsCopyObjectModel m = new MultiPartsCopyObjectModel();

        /// 初始化分片上传
        m.InitMultiUpload();
        /// 拷贝一个分片
        m.UploadPartCopy();
        /// 完成分片拷贝任务
        m.CompleteMultiUpload();
        // .cssg-methods-pragma
      }
    }
}
