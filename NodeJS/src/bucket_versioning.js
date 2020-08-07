var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶多版本
function putBucketVersioning() {
  //.cssg-snippet-body-start:[put-bucket-versioning]
  cos.putBucketVersioning({
      Bucket: 'examplebucket-1250000000',  /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      VersioningConfiguration: {
          Status: "Enabled"
      }
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶多版本状态
function getBucketVersioning() {
  //.cssg-snippet-body-start:[get-bucket-versioning]
  cos.getBucketVersioning({
      Bucket: 'examplebucket-1250000000',  /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketVersioning", function() {
  // 设置存储桶多版本
  it("putBucketVersioning", function() {
    return putBucketVersioning()
  })

  // 获取存储桶多版本状态
  it("getBucketVersioning", function() {
    return getBucketVersioning()
  })

  //.cssg-methods-pragma
})