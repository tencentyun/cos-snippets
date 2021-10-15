using COSXML.Model.CI;
using COSXML.Auth;
using System;
using COSXML;

namespace COSSnippet
{
    public class GetMediaInfoModel {

      private CosXml cosXml;

      GetMediaInfoModel() {
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

      /// 获取媒体文件信息
      public void GetMediaInfo()
      {
        //.cssg-snippet-body-start:[GetMediaInfo]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000";
        string key = "mediafile"; // 媒体文件的对象键，需要替换成桶内存在的媒体文件的对象键
        GetMediaInfoRequest request = new GetMediaInfoRequest(bucket, key);
        // 执行请求
        GetMediaInfoResult result = cosXml.GetMediaInfo(request);
        Console.WriteLine(result.GetResultInfo());
        // 获取视频媒体信息
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Video);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Video.Index);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Video.CodecName);
        // 获取音频信息
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Audio);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Audio.Index);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Audio.CodecName);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Stream.Audio.CodecLongName);
        // 获取Format字段
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Format);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Format.NumStream);
        Console.WriteLine(result.mediaInfoResult.MediaInfo.Format.NumProgram);
        //.cssg-snippet-body-end
      }

      static void Main(string[] args)
      {
        GetMediaInfoModel m = new GetMediaInfoModel();
        /// 获取媒体文件信息
        m.GetMediaInfo();
        // .cssg-methods-pragma
      }
    }
}
