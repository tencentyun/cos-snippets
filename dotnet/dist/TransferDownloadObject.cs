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
    public class TransferDownloadObjectModel {

      private CosXml cosXml;

      TransferDownloadObjectModel() {
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

      /// 高级接口下载对象
      public void TransferDownloadObject()
      {
        //.cssg-snippet-body-start:[transfer-download-object]
        // 初始化 TransferConfig
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        string localFileName = "my-local-temp-file"; //指定本地保存的文件名
        
        // 下载对象
         // COS_REGION 为存储桶所在地域
        COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(bucket, "COS_REGION", cosPath, 
          localDir, localFileName);
        
        // 同步调用
        var autoEvent = new AutoResetEvent(false);
        
        downloadTask.progressCallback = delegate (long completed, long total)
        {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
        };
        downloadTask.successCallback = delegate (CosResult cosResult) 
        {
            COSXML.Transfer.COSXMLDownloadTask.DownloadTaskResult result = cosResult 
              as COSXML.Transfer.COSXMLDownloadTask.DownloadTaskResult;
            Console.WriteLine(result.GetResultInfo());
            string eTag = result.eTag;
            autoEvent.Set();
        };
        downloadTask.failCallback = delegate (CosClientException clientEx, CosServerException serverEx) 
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
        transferManager.Download(downloadTask);
        // 等待任务结束
        autoEvent.WaitOne();
        //.cssg-snippet-body-end
      }

      /// 下载暂停
      public void TransferDownloadObjectInteract()
      {
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        string localFileName = "my-local-temp-file"; //指定本地保存的文件名
        
        COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(bucket, "COS_REGION", cosPath, 
          localDir, localFileName);
        transferManager.Download(downloadTask);

        //.cssg-snippet-body-start:[transfer-download-object-pause]
        downloadTask.Pause();
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-download-object-resume]
        downloadTask.Resume();
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-download-object-cancel]
        downloadTask.Cancel();
        //.cssg-snippet-body-end
      }

      /// 批量下载
      public void TransferBatchDownloadObjects()
      {
        //.cssg-snippet-body-start:[transfer-batch-download-objects]
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        
        for (int i = 0; i < 5; i++) {
          // 上传对象
          string cosPath = "exampleobject" + i; //对象在存储桶中的位置标识符，即称对象键
          string localFileName = "my-local-temp-file"; //指定本地保存的文件名
          // COS_REGION 为存储桶所在地域
          COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(bucket, "COS_REGION", cosPath, 
            localDir, localFileName);
          transferManager.Download(downloadTask);
        }
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        TransferDownloadObjectModel m = new TransferDownloadObjectModel();

        /// 高级接口下载对象
        m.TransferDownloadObject();
        /// 下载暂停续传取消
        m.TransferDownloadObjectInteract();
        /// 批量下载
        m.TransferBatchDownloadObjects();
        // .cssg-methods-pragma
      }
    }
}