// 设置存储桶 ACL
function putBucketAcl(assert) {
  //.cssg-snippet-body-start:[put-bucket-acl]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      ACL: 'public-read'
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 ACL
function getBucketAcl(assert) {
  //.cssg-snippet-body-start:[get-bucket-acl]
  cos.getBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("BucketACL", async function(assert) {
  // 设置存储桶 ACL
  await putBucketAcl(assert)

  // 获取存储桶 ACL
  await getBucketAcl(assert)

//.cssg-methods-pragma
})