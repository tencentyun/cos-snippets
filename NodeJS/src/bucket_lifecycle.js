var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶生命周期
function putBucketLifecycle() {
  //.cssg-snippet-body-start:[put-bucket-lifecycle]
  cos.putBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Rules: [{
          "ID": "1",
          "Status": "Enabled",
          "Filter": {},
          "Transition": {
              "Days": "30",
              "StorageClass": "STANDARD_IA"
          }
      }],
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶生命周期
function getBucketLifecycle() {
  //.cssg-snippet-body-start:[get-bucket-lifecycle]
  cos.getBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶生命周期
function deleteBucketLifecycle() {
  //.cssg-snippet-body-start:[delete-bucket-lifecycle]
  cos.deleteBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketLifecycle", function() {
  // 设置存储桶生命周期
  it("putBucketLifecycle", function() {
    return putBucketLifecycle()
  })

  // 获取存储桶生命周期
  it("getBucketLifecycle", function() {
    return getBucketLifecycle()
  })

  // 删除存储桶生命周期
  it("deleteBucketLifecycle", function() {
    return deleteBucketLifecycle()
  })

  //.cssg-methods-pragma
})