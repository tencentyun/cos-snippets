// 删除存储桶
function deleteBucket(assert) {
  //.cssg-snippet-body-start:[delete-bucket]
  cos.deleteBucket({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶
function deleteBucketDomain(assert) {
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

test("DeleteBucket", async function(assert) {
  // 删除存储桶
  await deleteBucket(assert)

  // 删除存储桶
  await deleteBucketDomain(assert)

//.cssg-methods-pragma
})