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
    public class TransferUploadObjectModel {

      private CosXml cosXml;

      TransferUploadObjectModel() {
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

      /// 高级接口上传对象
      public async void TransferUploadFile()
      {
        //.cssg-snippet-body-start:[transfer-upload-file]
        // 初始化 TransferConfig
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = @"temp-source-file";//本地文件绝对路径
        
        // 上传对象
        COSXMLUploadTask uploadTask = new COSXMLUploadTask(bucket, cosPath);
        uploadTask.SetSrcPath(srcPath);
        
        uploadTask.progressCallback = delegate (long completed, long total)
        {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
        };

        try {
          COSXML.Transfer.COSXMLUploadTask.UploadTaskResult result = await 
            transferManager.UploadAsync(uploadTask);
          Console.WriteLine(result.GetResultInfo());
          string eTag = result.eTag;
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

      /// 高级接口上传二进制数据
      public void TransferUploadBytes()
      {
        //.cssg-snippet-body-start:[transfer-upload-bytes]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string cosPath = "exampleObject"; // 对象键
          byte[] data = new byte[1024]; // 二进制数据
          PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, data);
          
          cosXml.PutObject(putObjectRequest);
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

      /// 高级接口流式上传
      public void TransferUploadStream()
      {
        /// 暂不支持
        //.cssg-snippet-body-start:[transfer-upload-stream]
        
        //.cssg-snippet-body-end
      }

      /// 高级接口 URI 上传
      public void TransferUploadUri()
      {
        /// 暂不支持
        //.cssg-snippet-body-start:[transfer-upload-uri]
        
        //.cssg-snippet-body-end
      }

      /// 上传暂停、续传、取消
      public async void TransferUploadInteract()
      {
        TransferConfig transferConfig = new TransferConfig();
        
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
        string cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        
        // 上传对象
        COSXMLUploadTask uploadTask = new COSXMLUploadTask(bucket, cosPath);
        uploadTask.SetSrcPath(srcPath);

        await transferManager.UploadAsync(uploadTask);

        //.cssg-snippet-body-start:[transfer-upload-pause]
        uploadTask.Pause();
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-upload-resume]
        uploadTask.Resume();
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-upload-cancel]
        uploadTask.Cancel();
        //.cssg-snippet-body-end
      }

      /// 批量上传
      public async void TransferBatchUploadObjects()
      {
        //.cssg-snippet-body-start:[transfer-batch-upload-objects]
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
        
        for (int i = 0; i < 5; i++) {
          // 上传对象
          string cosPath = "exampleobject" + i; //对象在存储桶中的位置标识符，即称对象键
          string srcPath = @"temp-source-file";//本地文件绝对路径
          COSXMLUploadTask uploadTask = new COSXMLUploadTask(bucket, cosPath); 
          uploadTask.SetSrcPath(srcPath);
          await transferManager.UploadAsync(uploadTask);
        }
        //.cssg-snippet-body-end
      }

      /// 上传时对单链接限速
      public async void UploadObjectTrafficLimit()
      {
        //.cssg-snippet-body-start:[upload-object-traffic-limit]
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);

        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
        string cosPath = "dir/exampleObject"; // 对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径

        PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, srcPath);
        putObjectRequest.LimitTraffic(8 * 1000 * 1000); // 限制为1MB/s

        COSXMLUploadTask uploadTask = new COSXMLUploadTask(putObjectRequest);

        uploadTask.SetSrcPath(srcPath);

        await transferManager.UploadAsync(uploadTask);
        //.cssg-snippet-body-end
      }

      /// 创建目录
      public void CreateDirectory()
      {
        //.cssg-snippet-body-start:[create-directory]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string cosPath = "dir/"; // 对象键
          PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, cosPath, new byte[0]);
          
          cosXml.PutObject(putObjectRequest);
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
        TransferUploadObjectModel m = new TransferUploadObjectModel();

        /// 高级接口上传对象
        m.TransferUploadFile();
        /// 高级接口上传二进制数据
        m.TransferUploadBytes();
        /// 高级接口流式上传
        m.TransferUploadStream();
        /// 高级接口 URI 上传
        m.TransferUploadUri();
        /// 上传暂停续传取消
        m.TransferUploadInteract();
        /// 批量上传
        m.TransferBatchUploadObjects();

        /// 上传时对单链接限速
        m.UploadObjectTrafficLimit();
        /// 创建目录
        m.CreateDirectory();
        // .cssg-methods-pragma
      }
    }
}
