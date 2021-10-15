using COSXML.Model.CI;
using COSXML.Auth;
using System;
using COSXML;

namespace COSSnippet
{
    public class GetSnapshotModel {

      private CosXml cosXml;

      GetSnapshotModel() {
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

      /// 视频截帧
      public void GetSnapshot()
      {
        //.cssg-snippet-body-start:[GetSnapshot]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000";
        string key = "video.mp4"; // 媒体文件的对象键，需要替换成桶内存在的媒体文件的对象键
        float time = 1.5F; // 截取的具体时间，用浮点数表示
        string destPath = @"temp-source-file"; // 截图文件保存路径, 需要替换成本地具体路径, 例如"/usr/local/"
        GetSnapshotRequest request = new GetSnapshotRequest(bucket, key, time, destPath);
        // 执行请求
        GetSnapshotResult result = cosXml.GetSnapshot(request);
        Console.WriteLine(result.GetResultInfo());
        //.cssg-snippet-body-end
      }

      static void Main(string[] args)
      {
        GetSnapshotModel m = new GetSnapshotModel();
        /// 视频截帧
        m.GetSnapshot();
        // .cssg-methods-pragma
      }
    }
}
