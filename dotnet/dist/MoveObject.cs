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
    public class MoveObjectModel {

      private CosXml cosXml;

      MoveObjectModel() {
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

      /// 移动对象
      public async void MoveObject()
      {
        TransferConfig transferConfig = new TransferConfig();
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);

        //.cssg-snippet-body-start:[move-object]
        string sourceAppid = "1250000000"; //账号 appid
        string sourceBucket = "sourcebucket-1250000000"; //"源对象所在的存储桶
        string sourceRegion = "COS_REGION"; //源对象的存储桶所在的地域
        string sourceKey = "sourceObject"; //源对象键
        //构造源对象属性
        CopySourceStruct copySource = new CopySourceStruct(sourceAppid, sourceBucket, 
            sourceRegion, sourceKey);

        string bucket = "examplebucket-1250000000"; //目标存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //目标对象的对象键

        COSXMLCopyTask copyTask = new COSXMLCopyTask(bucket, key, copySource);
        
        try {
          // 拷贝对象
          COSXML.Transfer.COSXMLCopyTask.CopyTaskResult result = await 
            transferManager.CopyAsync(copyTask);
          Console.WriteLine(result.GetResultInfo());

          // 删除对象
          DeleteObjectRequest request = new DeleteObjectRequest(sourceBucket, sourceKey);
          DeleteObjectResult deleteResult = cosXml.DeleteObject(request);
          // 打印结果
          Console.WriteLine(deleteResult.GetResultInfo());
        } catch (Exception e) {
            Console.WriteLine("CosException: " + e);
        }
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        MoveObjectModel m = new MoveObjectModel();

        /// 移动对象
        m.MoveObject();
        // .cssg-methods-pragma
      }
    }
}