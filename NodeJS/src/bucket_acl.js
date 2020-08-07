var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶 ACL
function putBucketAcl() {
  //.cssg-snippet-body-start:[put-bucket-acl]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      ACL: 'public-read'
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 ACL
function getBucketAcl() {
  //.cssg-snippet-body-start:[get-bucket-acl]
  cos.getBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION'     /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketACL", function() {
  // 设置存储桶 ACL
  it("putBucketAcl", function() {
    return putBucketAcl()
  })

  // 获取存储桶 ACL
  it("getBucketAcl", function() {
    return getBucketAcl()
  })

  //.cssg-methods-pragma
})