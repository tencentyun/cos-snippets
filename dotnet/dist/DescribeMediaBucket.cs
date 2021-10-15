using COSXML.Model.CI;
using COSXML.Auth;
using System;
using COSXML;

namespace COSSnippet
{
    public class DescribeMediaBucketModel {

      private CosXml cosXml;

      DescribeMediaBucketModel() {
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

      /// 获取开通了万象功能的 Buckets 列表
      public void DescribeMediaBucket()
      {
        //.cssg-snippet-body-start:[DescribeMediaBucket]
        DescribeMediaBucketsRequest request = new DescribeMediaBucketsRequest();
        // 执行请求
        DescribeMediaBucketsResult result = cosXml.DescribeMediaBuckets(request);
        Console.WriteLine(result.GetResultInfo());
        // 遍历Bucket列表
        for (int i = 0; i < result.mediaBuckets.MediaBucketList.Count; i++)
        {
          Console.WriteLine(result.mediaBuckets.MediaBucketList[i].BucketId);
          Console.WriteLine(result.mediaBuckets.MediaBucketList[i].Region);
          Console.WriteLine(result.mediaBuckets.MediaBucketList[i].CreateTime);
        }
        //.cssg-snippet-body-end
      }

      static void Main(string[] args)
      {
        DescribeMediaBucketModel m = new DescribeMediaBucketModel();
        /// 获取媒体Buckets列表
        m.DescribeMediaBucket();
        // .cssg-methods-pragma
      }
    }
}
