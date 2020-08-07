// 设置存储桶多版本
function putBucketVersioning(assert) {
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
function getBucketVersioning(assert) {
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

test("BucketVersioning", async function(assert) {
  // 设置存储桶多版本
  await putBucketVersioning(assert)

  // 获取存储桶多版本状态
  await getBucketVersioning(assert)

//.cssg-methods-pragma
})