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
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .Build();
        
        string secretId = "SECRET_ID";   //云 API 密钥 SecretId
        string secretKey = "SECRET_KEY"; //云 API 密钥 SecretKey
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 高级接口下载对象
      public async void TransferDownloadObject()
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
        COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(bucket, cosPath, 
          localDir, localFileName);
        
        downloadTask.progressCallback = delegate (long completed, long total)
        {
            Console.WriteLine(String.Format("progress = {0:##.##}%", completed * 100.0 / total));
        };

        try {
          COSXML.Transfer.COSXMLDownloadTask.DownloadTaskResult result = await 
            transferManager.DownloadAsync(downloadTask);
          Console.WriteLine(result.GetResultInfo());
          string eTag = result.eTag;
        } catch (Exception e) {
            Console.WriteLine("CosException: " + e);
        }
        //.cssg-snippet-body-end
      }

      /// 下载暂停
      public void TransferDownloadObjectInteract()
      {

        //.cssg-snippet-body-start:[transfer-download-object-pause]
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-download-object-resume]
        //.cssg-snippet-body-end

        //.cssg-snippet-body-start:[transfer-download-object-cancel]
        //.cssg-snippet-body-end
      }

      /// 批量下载
      public async void TransferBatchDownloadObjects()
      {
        //.cssg-snippet-body-start:[transfer-batch-download-objects]
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        
        for (int i = 0; i < 5; i++) {
          // 下载对象
          string cosPath = "exampleobject" + i; //对象在存储桶中的位置标识符，即称对象键
          string localFileName = "my-local-temp-file"; //指定本地保存的文件名
          COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(bucket, cosPath, 
            localDir, localFileName);
          await transferManager.DownloadAsync(downloadTask);
        }
        //.cssg-snippet-body-end
      }

      /// 下载时对单链接限速
      public async void DownloadObjectTrafficLimit()
      {
        //.cssg-snippet-body-start:[download-object-traffic-limit]
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        string localFileName = "my-local-temp-file"; //指定本地保存的文件名
        
        GetObjectRequest request = new GetObjectRequest(bucket, 
                cosPath, localDir, localFileName);
        request.LimitTraffic(8 * 1000 * 1024); // 限制为1MB/s

        COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(request);
        await transferManager.DownloadAsync(downloadTask);
        //.cssg-snippet-body-end
      }

      /// 设置支持断点下载
      public async void TransferDownloadResumable()
      {
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);
        
        String bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        String cosPath = "exampleobject"; //对象在存储桶中的位置标识符，即称对象键
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        string localFileName = "my-local-temp-file"; //指定本地保存的文件名
        
        GetObjectRequest request = new GetObjectRequest(bucket, 
                cosPath, localDir, localFileName);
        //.cssg-snippet-body-start:[transfer-download-resumable]
        COSXMLDownloadTask downloadTask = new COSXMLDownloadTask(request);
        //开启断点续传，当本地存在未下载完成文件时，追加下载到文件末尾
        //本地文件已存在部分内容可能导致下载失败，请删除重试
        downloadTask.SetResumableDownload(true);
        try {
          COSXML.Transfer.COSXMLDownloadTask.DownloadTaskResult result = await 
            transferManager.DownloadAsync(downloadTask);
          Console.WriteLine(result.GetResultInfo());
          string eTag = result.eTag;
        } catch (Exception e) {
            Console.WriteLine("CosException: " + e);
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

        /// 下载时对单链接限速
        m.DownloadObjectTrafficLimit();

        /// 设置支持断点下载
        m.TransferDownloadResumable();
        // .cssg-methods-pragma
      }
    }
}
