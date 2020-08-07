var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 简单上传对象
function putObject() {
  //.cssg-snippet-body-start:[put-object]
  cos.putObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      StorageClass: 'STANDARD',
      Body: fs.createReadStream('./exampleobject'), // 上传文件对象
      onProgress: function(progressData) {
          console.log(JSON.stringify(progressData));
      }
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 简单上传对象
function putObjectBytes() {
  //.cssg-snippet-body-start:[put-object-bytes]
  cos.putObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      Body: Buffer.from('hello!'), /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 简单上传对象
function putObjectString() {
  //.cssg-snippet-body-start:[put-object-string]
  cos.putObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      Body: 'hello!',
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 简单上传对象
function putObjectFolder() {
  //.cssg-snippet-body-start:[put-object-folder]
  cos.putObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'a/',              /* 必须 */
      Body: '',
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("PutObject", function() {
  // 简单上传对象
  it("putObject", function() {
    return putObject()
  })

  // 简单上传对象
  it("putObjectBytes", function() {
    return putObjectBytes()
  })

  // 简单上传对象
  it("putObjectString", function() {
    return putObjectString()
  })

  // 简单上传对象
  it("putObjectFolder", function() {
    return putObjectFolder()
  })

  //.cssg-methods-pragma
})