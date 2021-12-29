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
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
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
        
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
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

      /// 文件夹批量下载
      public async Task TransferDownloadObjectsFromFolder()
      { 
        try
        {
          String nextMarker = null;
          // 注意：COS中实际不存在文件夹下载的接口
          // 需要通过组合 “指定前缀列出” 和 “遍历列出的对象key做下载” 两种操作，实现类似文件夹下载的操作
          // 下面的操作，把对象列出到队列里，然后异步下载队列中的对象
          TransferConfig transferConfig = new TransferConfig();
          
          // 初始化 TransferManager
          TransferManager transferManager = new TransferManager(cosXml, transferConfig);
          
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          string localDir = System.IO.Path.GetTempPath();//本地文件夹

          // 循环请求直到没有下一页数据
          do
          {
            // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
            string prefix = "folder1/"; // 指定文件夹前缀
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
            foreach (var content in objects)
            {
              // 下载对象
            }
          } while (nextMarker != null);
        //.cssg-snippet-body-end
        }
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
