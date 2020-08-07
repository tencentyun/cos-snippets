// 初始化分片上传
function initMultiUpload(assert) {
  //.cssg-snippet-body-start:[init-multi-upload]
  cos.multipartInit({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      UploadId: 'exampleUploadId',
      Body: fileObject
  }, function(err, data) {
      console.log(err || data);
      if (data) {
        uploadId = data.UploadId;
      }
  });
  
  //.cssg-snippet-body-end
}

// 列出所有未完成的分片上传任务
function listMultiUpload(assert) {
  //.cssg-snippet-body-start:[list-multi-upload]
  cos.multipartList({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Prefix: 'exampleobject',                        /* 非必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 上传一个分片
function uploadPart(assert) {
  //.cssg-snippet-body-start:[upload-part]
  cos.multipartUpload({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',       /* 必须 */
      UploadId: 'exampleUploadId',
      PartNumber: '1',
      Body: fileObject
  }, function(err, data) {
      console.log(err || data);
      if (data) {
        eTag = data.ETag;
      }
  });
  
  //.cssg-snippet-body-end
}

// 列出已上传的分片
function listParts(assert) {
  //.cssg-snippet-body-start:[list-parts]
  cos.multipartListPart({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      UploadId: 'exampleUploadId',    /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 完成分片上传任务
function completeMultiUpload(assert) {
  //.cssg-snippet-body-start:[complete-multi-upload]
  cos.multipartComplete({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
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

test("MultiPartsUploadObject", async function(assert) {
  // 初始化分片上传
  await initMultiUpload(assert)

  // 列出所有未完成的分片上传任务
  await listMultiUpload(assert)

  // 上传一个分片
  await uploadPart(assert)

  // 列出已上传的分片
  await listParts(assert)

  // 完成分片上传任务
  await completeMultiUpload(assert)

//.cssg-methods-pragma
})