// 高级接口上传对象
function transferUploadFile(assert) {
  //.cssg-snippet-body-start:[transfer-upload-file]
  cos.sliceUploadFile({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      Body: fileObject,                /* 必须 */
      onTaskReady: function(taskId) {                   /* 非必须 */
          console.log(taskId);
      },
      onHashProgress: function (progressData) {       /* 非必须 */
          console.log(JSON.stringify(progressData));
      },
      onProgress: function (progressData) {           /* 非必须 */
          console.log(JSON.stringify(progressData));
      }
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 批量上传
function transferBatchUploadObjects(assert) {
  //.cssg-snippet-body-start:[transfer-batch-upload-objects]
  cos.uploadFiles({
      files: [{
          Bucket: 'examplebucket-1250000000', // Bucket 格式：BucketName-APPID
          Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
          Key: 'exampleobject',
          Body: fileObject1,
      }, {
          Bucket: 'examplebucket-1250000000', // Bucket 格式：BucketName-APPID
          Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
          Key: 'exampleobject2',
          Body: fileObject2,
      }],
      SliceSize: 1024 * 1024,
      onProgress: function (info) {
          var percent = parseInt(info.percent * 10000) / 100;
          var speed = parseInt(info.speed / 1024 / 1024 * 100) / 100;
          console.log('进度：' + percent + '%; 速度：' + speed + 'Mb/s;');
      },
      onFileFinish: function (err, data, options) {
          console.log(options.Key + '上传' + (err ? '失败' : '完成'));
      },
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("TransferUploadObject", async function(assert) {
  // 高级接口上传对象
  await transferUploadFile(assert)

  // 批量上传
  await transferBatchUploadObjects(assert)

//.cssg-methods-pragma
})