// 设置存储桶跨地域复制规则
function putBucketReplication(assert) {
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
function getBucketReplication(assert) {
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
function deleteBucketReplication(assert) {
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

test("BucketReplication", async function(assert) {
  // 设置存储桶跨地域复制规则
  await putBucketReplication(assert)

  // 获取存储桶跨地域复制规则
  await getBucketReplication(assert)

  // 删除存储桶跨地域复制规则
  await deleteBucketReplication(assert)

//.cssg-methods-pragma
})