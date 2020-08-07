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

// 终止分片上传任务
function abortMultiUpload(assert) {
  //.cssg-snippet-body-start:[abort-multi-upload]
  cos.multipartAbort({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',                           /* 必须 */
      UploadId: 'exampleUploadId'    /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("AbortMultiPartsUpload", async function(assert) {
  // 初始化分片上传
  await initMultiUpload(assert)

  // 终止分片上传任务
  await abortMultiUpload(assert)

//.cssg-methods-pragma
})