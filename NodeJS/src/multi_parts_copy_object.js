var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 初始化分片上传
function initMultiUpload() {
  //.cssg-snippet-body-start:[init-multi-upload]
  cos.multipartInit({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
  }, function(err, data) {
      console.log(err || data);
      if (data) {
        uploadId = data.UploadId;
      }
  });
  
  //.cssg-snippet-body-end
}

// 拷贝一个分片
function uploadPartCopy() {
  //.cssg-snippet-body-start:[upload-part-copy]
  cos.uploadPartCopy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',       /* 必须 */
      CopySource: 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject', /* 必须 */
      UploadId: 'exampleUploadId', /* 必须 */
      PartNumber: '1', /* 必须 */
  }, function(err, data) {
      console.log(err || data);
      if (data) {
        eTag = data.ETag;
      }
  });
  
  //.cssg-snippet-body-end
}

// 完成分片拷贝任务
function completeMultiUpload() {
  //.cssg-snippet-body-start:[complete-multi-upload]
  cos.multipartComplete({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      UploadId: 'exampleUploadId', /* 必须 */
      Parts: [
          {PartNumber: '1', ETag: 'exampleETag'},
      ]
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("MultiPartsCopyObject", function() {
  // 初始化分片上传
  it("initMultiUpload", function() {
    return initMultiUpload()
  })

  // 拷贝一个分片
  it("uploadPartCopy", function() {
    return uploadPartCopy()
  })

  // 完成分片拷贝任务
  it("completeMultiUpload", function() {
    return completeMultiUpload()
  })

  //.cssg-methods-pragma
})