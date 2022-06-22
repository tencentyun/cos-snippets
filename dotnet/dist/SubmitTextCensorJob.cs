using COSXML.Model.CI;
using COSXML.Auth;
using System;
using System.Text;
using System.Threading;
using COSXML;

namespace COSSnippet
{
    public class SubmitTextCensorJobModel {

      private CosXml cosXml;

      SubmitTextCensorJobModel() {
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

      /// 提交文本审核任务
      public string SubmitTextCensorJob()
      {
        //.cssg-snippet-body-start:[SubmitAudioCensorJob]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        SubmitTextCensorJobRequest request = new SubmitTextCensorJobRequest(bucket);
        request.SetCensorObject("text.txt"); // 媒体文件的对象键，需要替换成桶内存在的媒体文件的对象键
        // 审核的场景类型，有效值：Porn（涉黄）、Terrorism（涉暴恐）、Politics（政治敏感）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Terrorism
        request.SetDetectType("Porn,Terrorism");
        // 执行请求
        SubmitCensorJobResult result = cosXml.SubmitTextCensorJob(request);
        Console.WriteLine(result.GetResultInfo());
        Console.WriteLine(result.censorJobsResponse.JobsDetail.JobId);
        Console.WriteLine(result.censorJobsResponse.JobsDetail.State);
        Console.WriteLine(result.censorJobsResponse.JobsDetail.CreationTime);
        return result.censorJobsResponse.JobsDetail.JobId;
        //.cssg-snippet-body-end
      }

      /// 查询文本审核任务结果
      public void GetTextCensorJobResult(string JobId)
      {
        //.cssg-snippet-body-start:[GetTextCensorJobResult]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        GetTextCensorJobRequest request = new GetTextCensorJobRequest(bucket, JobId);
        // 执行请求
        GetTextCensorJobResult result = cosXml.GetTextCensorJob(request);
        Console.WriteLine(result.GetResultInfo());

        // 读取审核结果
        Console.WriteLine(result.resultStruct.JobsDetail.JobId);
        Console.WriteLine(result.resultStruct.JobsDetail.State);
        Console.WriteLine(result.resultStruct.JobsDetail.CreationTime);
        Console.WriteLine(result.resultStruct.JobsDetail.Object);
        Console.WriteLine(result.resultStruct.JobsDetail.SectionCount);
        Console.WriteLine(result.resultStruct.JobsDetail.Result);

        Console.WriteLine(result.resultStruct.JobsDetail.PornInfo.HitFlag);
        Console.WriteLine(result.resultStruct.JobsDetail.PornInfo.Count);
        Console.WriteLine(result.resultStruct.JobsDetail.TerrorismInfo.HitFlag);
        Console.WriteLine(result.resultStruct.JobsDetail.TerrorismInfo.Count);

        // 文本节选Section信息
        for(int i = 0; i < result.resultStruct.JobsDetail.Section.Count; i++)
        {
            Console.WriteLine(result.resultStruct.JobsDetail.Section[i].StartByte);
            Console.WriteLine(result.resultStruct.JobsDetail.Section[i].PornInfo.HitFlag);
            Console.WriteLine(result.resultStruct.JobsDetail.Section[i].PornInfo.Score);
            Console.WriteLine(result.resultStruct.JobsDetail.Section[i].PornInfo.Keywords);
        }
        //.cssg-snippet-body-end
      }

      /// 提交同步审核的文本审核任务
      public void SubmitTextCensorJobSync()
      {
        //.cssg-snippet-body-start:[SubmitAudioCensorJob]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        SubmitTextCensorJobRequest request = new SubmitTextCensorJobRequest(bucket);
        request.SetCensorContent(Convert.ToBase64String(Encoding.UTF8.GetBytes("文本审核内容"))); // 需要审核的文本内容，注意需要base64编码后传入
        // 审核的场景类型，有效值：Porn（涉黄）、Terrorism（涉暴恐）、Politics（政治敏感）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Terrorism
        request.SetDetectType("Porn,Terrorism");
        // 执行请求
        SubmitTextCensorJobsResult result = new SubmitTextCensorJobsResult();
        try {
            result = cosXml.SubmitTextCensorJobSync(request);
        } catch (COSXML.CosException.CosClientException clientEx) {
          //请求失败
          Console.WriteLine("CosClientException: " + clientEx);
        }
        catch (COSXML.CosException.CosServerException serverEx) {
          //请求失败
          Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        Console.WriteLine(result.GetResultInfo());
        Console.WriteLine(result.textCensorJobsResponse.JobsDetail.JobId);
        Console.WriteLine(result.textCensorJobsResponse.JobsDetail.Result);
        Console.WriteLine(result.textCensorJobsResponse.JobsDetail.SectionCount);
        //.cssg-snippet-body-end
      }

      static void Main(string[] args)
      {
        SubmitTextCensorJobModel m = new SubmitTextCensorJobModel();
        /// 提交同步审核任务
        m.SubmitTextCensorJobSync();
        /// 提交审核任务
        string JobId = m.SubmitTextCensorJob();
        Thread.Sleep(30000);
        m.GetTextCensorJobResult(JobId);
        // .cssg-methods-pragma
      }
    }
}
