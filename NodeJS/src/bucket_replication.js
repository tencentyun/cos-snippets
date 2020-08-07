var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶跨地域复制规则
function putBucketReplication() {
  //.cssg-snippet-body-start:[put-bucket-replication]
  cos.putBucketReplication({
      Bucket: 'examplebucket-1250000000',  /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      ReplicationConfiguration: { /* 必须 */
          Role: "qcs::cam::uin/100000000001:uin/100000000001",
          Rules: [{
              ID: "1",
              Status: "Enabled",
              Prefix: "sync/",
              Destination: {
                  Bucket: "qcs::cos:ap-beijing::destinationbucket-1250000000",
                  StorageClass: "Standard",
              }
          }]
      }
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶跨地域复制规则
function getBucketReplication() {
  //.cssg-snippet-body-start:[get-bucket-replication]
  cos.getBucketReplication({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶跨地域复制规则
function deleteBucketReplication() {
  //.cssg-snippet-body-start:[delete-bucket-replication]
  cos.deleteBucketReplication({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketReplication", function() {
  // 设置存储桶跨地域复制规则
  it("putBucketReplication", function() {
    return putBucketReplication()
  })

  // 获取存储桶跨地域复制规则
  it("getBucketReplication", function() {
    return getBucketReplication()
  })

  // 删除存储桶跨地域复制规则
  it("deleteBucketReplication", function() {
    return deleteBucketReplication()
  })

  //.cssg-methods-pragma
})