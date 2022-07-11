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
using System.Diagnostics;

namespace COSSnippet
{
    public class TransferUploadObjectModel {

      private CosXml cosXml;

      TransferUploadObjectModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .SetDebugLog(true) // 设置SDK开启DEBUG日志记录, 细粒度HTTP请求过程将被记录到Trace下
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 高级接口上传对象
      public async Task TransferUploadFile()
      {
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

      }

      static void Main(string[] args)
      {
        TransferUploadObjectModel m = new TransferUploadObjectModel();
        // 自定义日志路径
        Stream sdkLogFile = File.Create("COSXML.log");
        Trace.Listeners.Add(new TextWriterTraceListener(sdkLogFile));
        // 进行SDK调用
        m.TransferUploadFile().Wait();
        // 写入日志
        Trace.Flush();
      }
    }
}
