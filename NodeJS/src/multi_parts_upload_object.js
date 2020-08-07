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

// 列出所有未完成的分片上传任务
function listMultiUpload() {
  //.cssg-snippet-body-start:[list-multi-upload]
  cos.multipartList({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Prefix: 'exampleobject',                        /* 非必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 上传一个分片
function uploadPart() {
  //.cssg-snippet-body-start:[upload-part]
  const filePath = "temp-file-to-upload" // 本地文件路径
  cos.multipartUpload({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',       /* 必须 */
      ContentLength: '1024',
      UploadId: 'exampleUploadId',
      PartNumber: '1',
      Body: fs.createReadStream(filePath)
  }, function(err, data) {
      console.log(err || data);
      if (data) {
        eTag = data.ETag;
      }
  });
  
  //.cssg-snippet-body-end
}

// 列出已上传的分片
function listParts() {
  //.cssg-snippet-body-start:[list-parts]
  cos.multipartListPart({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      UploadId: 'exampleUploadId',                      /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 完成分片上传任务
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

describe("MultiPartsUploadObject", function() {
  // 初始化分片上传
  it("initMultiUpload", function() {
    return initMultiUpload()
  })

  // 列出所有未完成的分片上传任务
  it("listMultiUpload", function() {
    return listMultiUpload()
  })

  // 上传一个分片
  it("uploadPart", function() {
    return uploadPart()
  })

  // 列出已上传的分片
  it("listParts", function() {
    return listParts()
  })

  // 完成分片上传任务
  it("completeMultiUpload", function() {
    return completeMultiUpload()
  })

  //.cssg-methods-pragma
})