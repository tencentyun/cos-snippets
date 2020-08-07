var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 高级接口上传对象
function transferUploadFile() {
  //.cssg-snippet-body-start:[transfer-upload-file]
  const filePath = "temp-file-to-upload" // 本地文件路径
  cos.sliceUploadFile({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      FilePath: filePath,                /* 必须 */
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
function transferBatchUploadObjects() {
  //.cssg-snippet-body-start:[transfer-batch-upload-objects]
  const filePath1 = "temp-file-to-upload" // 本地文件路径
  const filePath2 = "temp-file-to-upload" // 本地文件路径
  cos.uploadFiles({
      files: [{
          Bucket: 'examplebucket-1250000000',
          Region: 'COS_REGION',
          Key: 'exampleobject',
          FilePath: filePath1,
      }, {
          Bucket: 'examplebucket-1250000000',
          Region: 'COS_REGION',
          Key: '2.jpg',
          FilePath: filePath2,
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

describe("TransferUploadObject", function() {
  // 高级接口上传对象
  it("transferUploadFile", function() {
    return transferUploadFile()
  })

  // 批量上传
  it("transferBatchUploadObjects", function() {
    return transferBatchUploadObjects()
  })

  //.cssg-methods-pragma
})