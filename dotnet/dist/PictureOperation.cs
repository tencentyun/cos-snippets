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
        //.cssg-snippet-body-end
      }

      /// 对云上数据进行图片处理
      public void ProcessWithPicOperation()
      {
        //.cssg-snippet-body-start:[process-with-pic-operation]
        
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

        request.SetRequestHeader("Pic-Operation", o.ToString());
        //执行请求
        PutObjectResult result = cosXml.PutObject(request);
        //.cssg-snippet-body-end
      }

      /// 下载时添加盲水印
      public void DownloadObjectWithWatermark()
      {
        //.cssg-snippet-body-start:[download-object-with-watermark]
        
        //.cssg-snippet-body-end
      }

      /// 图片审核
      public void SensitiveContentRecognition()
      {
        //.cssg-snippet-body-start:[sensitive-content-recognition]
        
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
        // .cssg-methods-pragma
      }
    }
}