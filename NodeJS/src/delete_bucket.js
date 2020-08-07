var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 删除存储桶
function deleteBucket() {
  //.cssg-snippet-body-start:[delete-bucket]
  cos.deleteBucket({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION'     /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶
function deleteBucketDomain() {
  //.cssg-snippet-body-start:[delete-bucket-domain]
  cos.deleteBucketDomain({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("DeleteBucket", function() {
  // 删除存储桶
  it("deleteBucket", function() {
    return deleteBucket()
  })

  // 删除存储桶
  it("deleteBucketDomain", function() {
    return deleteBucketDomain()
  })

  //.cssg-methods-pragma
})