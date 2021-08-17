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
    public class SetCustomHeadersModel {

      private CosXml cosXml;

      SetCustomHeadersModel() {
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

      /// 设置自定义头部
      public void SetCustomHeaders()
      {
        string bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //对象键
        string srcPath = @"temp-source-file";//本地文件绝对路径
        //.cssg-snippet-body-start:[set-custom-headers]
        PutObjectRequest request = new PutObjectRequest(bucket, key, srcPath);

        request.SetRequestHeader("x-cos-meta-key", "value");
        request.SetRequestHeader("Content-Disposition", "attachment");

        COSXMLUploadTask uploadTask = new COSXMLUploadTask(request);
        uploadTask.SetSrcPath(srcPath);
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        SetCustomHeadersModel m = new SetCustomHeadersModel();

        /// 设置自定义头部
        m.SetCustomHeaders();
        // .cssg-methods-pragma
      }
    }
}
