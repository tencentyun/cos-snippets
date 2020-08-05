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
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace COSSnippet
{
    public class PictureOperationModel {

      private CosXml cosXml;

      PictureOperationModel() {
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

      /// 上传时图片处理
      public void UploadWithPicOperation()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[upload-with-pic-operation]
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);
        //设置签名有效时长
        request.SetSign(TimeUtils.GetCurrentTime(TimeUnit.SECONDS), 600);

        JObject o = new JObject();
        // 不返回原图
        o["is_pic_info"] = 0;
        JArray rules = new JArray();
        JObject rule = new JObject();
        rule["bucket"] = bucket;
        rule["fileid"] = key;
        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/6924
        //这里以图片等比缩放到 400x400 像素以内为例
        rule["rule"] = "imageView2/thumbnail/400x400";
        rules.Add(rule);
        o["rules"] = rules;

        request.SetRequestHeader("Pic-Operation", o.ToString());
        //执行请求
        PutObjectResult result = cosXml.PutObject(request);
        Dictionary<string, List<string>> headers = result.responseHeaders;
        // 可以从 picProcessInfo 获取图片处理结果
        object ProcessResults = headers["ProcessResults"];
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        PictureOperationModel m = new PictureOperationModel();

        /// 上传时图片处理
        m.UploadWithPicOperation();
        // .cssg-methods-pragma
      }
    }
}