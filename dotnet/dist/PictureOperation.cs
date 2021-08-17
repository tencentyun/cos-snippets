using COSXML.Common;
using COSXML.CosException;
using COSXML.Model;
using COSXML.Model.Object;
using COSXML.Model.Tag;
using COSXML.Model.CI;
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
          .SetRegion("COS_REGION") //设置一个默认的存储桶地域
          .Build();
        
        string secretId = "SECRET_ID";   //云 API 密钥 SecretId
        string secretKey = "SECRET_KEY"; //云 API 密钥 SecretKey
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

        JObject o = new JObject();
        // 不返回原图
        o["is_pic_info"] = 0;
        JArray rules = new JArray();
        JObject rule = new JObject();
        rule["bucket"] = bucket;
        rule["fileid"] = "desample_photo.jpg";
        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/19017
        rule["rule"] = "imageMogr2/thumbnail/400x400";
        rules.Add(rule);
        o["rules"] = rules;

        string ruleString = o.ToString(Formatting.None);
        request.SetRequestHeader("Pic-Operations", ruleString);
        //执行请求
        PutObjectResult result = cosXml.PutObject(request);
        //.cssg-snippet-body-end
      }

      /// 对云上数据进行图片处理
      public void ProcessWithPicOperation()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[process-with-pic-operation]
        JObject o = new JObject();
        // 不返回原图
        o["is_pic_info"] = 0;
        JArray rules = new JArray();
        JObject rule = new JObject();
        rule["bucket"] = bucket;
        rule["fileid"] = "desample_photo.jpg";
        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/19017
        rule["rule"] = "imageMogr2/thumbnail/400x400";
        rules.Add(rule);
        o["rules"] = rules;
        string ruleString = o.ToString(Formatting.None);

        ImageProcessRequest request = new ImageProcessRequest(bucket, key, ruleString);
        ImageProcessResult result = cosXml.ImageProcess(request);
        //.cssg-snippet-body-end
      }

      /// 上传时添加盲水印
      public void PutObjectWithWatermark()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[put-object-with-watermark]
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);

        JObject o = new JObject();
        // 不返回原图
        o["is_pic_info"] = 0;
        JArray rules = new JArray();
        JObject rule = new JObject();
        rule["bucket"] = bucket;
        rule["fileid"] = key;
        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/19017
        rule["rule"] = "watermark/3/type/<type>/image/<imageUrl>/text/<text>/level/<level>";
        rules.Add(rule);
        o["rules"] = rules;

        string ruleString = o.ToString(Formatting.None);
        request.SetRequestHeader("Pic-Operations", ruleString);
        //执行请求
        PutObjectResult result = cosXml.PutObject(request);
        //.cssg-snippet-body-end
      }

      /// 下载时添加盲水印
      public void DownloadObjectWithWatermark()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        string localFileName = "my-local-temp-file"; //指定本地保存的文件名
        //.cssg-snippet-body-start:[download-object-with-watermark]
        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, key, localDir, localFileName);
        //处理参数，规则参见：https://cloud.tencent.com/document/product/460/19017
        getObjectRequest.SetQueryParameter("watermark/3/type/<type>/image/<imageUrl>/text/<text>", null);

        GetObjectResult result = cosXml.GetObject(getObjectRequest);
        //.cssg-snippet-body-end
      }

      /// 图片审核
      public void SensitiveContentRecognition()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        //.cssg-snippet-body-start:[sensitive-content-recognition]
        SensitiveContentRecognitionRequest request = 
          new SensitiveContentRecognitionRequest(bucket, key, "politics");
        SensitiveContentRecognitionResult result = cosXml.SensitiveContentRecognition(request);
        //.cssg-snippet-body-end
      }

      /// 下载时进行图片处理
      public void DownloadWithPicOperation()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string localDir = System.IO.Path.GetTempPath();//本地文件夹
        string localFileName = "my-local-temp-file"; //指定本地保存的文件名
        //.cssg-snippet-body-start:[download-with-pic-operation]
        GetObjectRequest getObjectRequest = new GetObjectRequest(bucket, key, localDir, localFileName);
        //处理参数，这里的实例是格式转换为 TPG 图片，规则参见：https://cloud.tencent.com/document/product/460/19017
        getObjectRequest.SetQueryParameter("imageMogr2/format/tpg", null);
        
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        PictureOperationModel m = new PictureOperationModel();

        /// 上传时图片处理
        m.UploadWithPicOperation();

        /// 对云上数据进行图片处理
        m.ProcessWithPicOperation();
        /// 上传时添加盲水印
        m.PutObjectWithWatermark();
        /// 下载时添加盲水印
        m.DownloadObjectWithWatermark();
        /// 图片审核
        m.SensitiveContentRecognition();

        /// 下载时进行图片处理
        m.DownloadWithPicOperation();
        // .cssg-methods-pragma
      }
    }
}
