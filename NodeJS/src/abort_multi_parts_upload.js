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

// 终止分片上传任务
function abortMultiUpload() {
  //.cssg-snippet-body-start:[abort-multi-upload]
  cos.multipartAbort({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',                           /* 必须 */
      UploadId: 'exampleUploadId'                       /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("AbortMultiPartsUpload", function() {
  // 初始化分片上传
  it("initMultiUpload", function() {
    return initMultiUpload()
  })

  // 终止分片上传任务
  it("abortMultiUpload", function() {
    return abortMultiUpload()
  })

  //.cssg-methods-pragma
})