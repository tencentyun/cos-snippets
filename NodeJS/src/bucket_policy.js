var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶 Policy
function putBucketPolicy() {
  //.cssg-snippet-body-start:[put-bucket-policy]
  cos.putBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Policy: {
          "version": "2.0",
          "Statement": [{
              "Effect": "allow",
              "Principal": {
                  "qcs": ["qcs::cam::uin/100000000001:uin/100000000001"]
              },
              "Action": [
                  "name/cos:PutObject",
                  "name/cos:InitiateMultipartUpload",
                  "name/cos:ListMultipartUploads",
                  "name/cos:ListParts",
                  "name/cos:UploadPart",
                  "name/cos:CompleteMultipartUpload"
              ],
              "Resource": ["qcs::cos:ap-guangzhou:uid/1250000000:examplebucket-1250000000/*"],
          }]
      },
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 Policy
function getBucketPolicy() {
  //.cssg-snippet-body-start:[get-bucket-policy]
  cos.getBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶 Policy
function deleteBucketPolicy() {
  //.cssg-snippet-body-start:[delete-bucket-policy]
  cos.deleteBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketPolicy", function() {
  // 设置存储桶 Policy
  it("putBucketPolicy", function() {
    return putBucketPolicy()
  })

  // 获取存储桶 Policy
  it("getBucketPolicy", function() {
    return getBucketPolicy()
  })

  // 删除存储桶 Policy
  it("deleteBucketPolicy", function() {
    return deleteBucketPolicy()
  })

  //.cssg-methods-pragma
})