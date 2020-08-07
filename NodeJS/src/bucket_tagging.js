var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶标签
function putBucketTagging() {
  //.cssg-snippet-body-start:[put-bucket-tagging]
  cos.putBucketTagging({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Tagging: {
          Tags: [
              {"Key": "k1", "Value": "v1"},
              {"Key": "k2", "Value": "v2"}
          ]
      }
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶标签
function getBucketTagging() {
  //.cssg-snippet-body-start:[get-bucket-tagging]
  cos.getBucketTagging({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶标签
function deleteBucketTagging() {
  //.cssg-snippet-body-start:[delete-bucket-tagging]
  cos.deleteBucketTagging({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketTagging", function() {
  // 设置存储桶标签
  it("putBucketTagging", function() {
    return putBucketTagging()
  })

  // 获取存储桶标签
  it("getBucketTagging", function() {
    return getBucketTagging()
  })

  // 删除存储桶标签
  it("deleteBucketTagging", function() {
    return deleteBucketTagging()
  })

  //.cssg-methods-pragma
})