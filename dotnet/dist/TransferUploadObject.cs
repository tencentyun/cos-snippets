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

      /// 高级接口上传对象
      public void TransferUploadFile()
      {
        //.cssg-snippet-body-start:[transfer-upload-file]
        // 初始化 TransferConfig
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        String srcPath = @"temp-source-file";//本地文件绝对路径
        if (!File.Exists(srcPath)) {
          // 如果不存在目标文件，创建一个临时的测试文件
          File.WriteAllBytes(srcPath, new byte[1024]);
        }
        
        // 上传对象
        COSXMLUploadTask uploadTask = new COSXMLUploadTask(bucket, "COS_REGION", cosPath); // COS_REGION 为存储桶所在地域
        uploadTask.SetSrcPath(srcPath);
        
        // 同步调用
        var autoEvent = new AutoResetEvent(false);
        
        uploadTask.progressCallback = delegate (long completed, long total)
        {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
        };
        uploadTask.successCallback = delegate (CosResult cosResult) 
        {
            COSXML.Transfer.COSXMLUploadTask.UploadTaskResult result = cosResult 
              as COSXML.Transfer.COSXMLUploadTask.UploadTaskResult;
            Console.WriteLine(result.GetResultInfo());
            string eTag = result.eTag;
            autoEvent.Set();
        };
        uploadTask.failCallback = delegate (CosClientException clientEx, CosServerException serverEx) 
        {
            if (clientEx != null)
            {
                Console.WriteLine("CosClientException: " + clientEx);
            }
            if (serverEx != null)
            {
                Console.WriteLine("CosServerException: " + serverEx.GetInfo());
            }
            autoEvent.Set();
        };
        transferManager.Upload(uploadTask);
        // 等待任务结束
        autoEvent.WaitOne();
        
        //.cssg-snippet-body-end
      }

      /// 高级接口上传二进制数据
      public void TransferUploadBytes()
      {
        /// 暂不支持
        //.cssg-snippet-body-start:[transfer-upload-bytes]
        
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
      public void TransferUploadInteract()
      {
        TransferConfig transferConfig = new TransferConfig();
        
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        
        // 上传对象
        COSXMLUploadTask uploadTask = new COSXMLUploadTask(bucket, "COS_REGION", cosPath);
        uploadTask.SetSrcPath(srcPath);

        transferManager.Upload(uploadTask);

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
      public void TransferBatchUploadObjects()
      {
        //.cssg-snippet-body-start:[transfer-batch-upload-objects]
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        
        for (int i = 0; i < 5; i++) {
          // 上传对象
          string cosPath = "exampleobject" + i; //对象在存储桶中的位置标识符，即称对象键
          string srcPath = @"temp-source-file";//本地文件绝对路径
          // COS_REGION 为存储桶所在地域
          COSXMLUploadTask uploadTask = new COSXMLUploadTask(bucket, "COS_REGION", cosPath); 
          uploadTask.SetSrcPath(srcPath);
          transferManager.Upload(uploadTask);
        }
        //.cssg-snippet-body-end
      }

      /// 上传时对单链接限速
      public void UploadObjectTrafficLimit()
      {
        //.cssg-snippet-body-start:[upload-object-traffic-limit]
        
        //.cssg-snippet-body-end
      }

      /// 创建目录
      public void CreateDirectory()
      {
        //.cssg-snippet-body-start:[create-directory]
        
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