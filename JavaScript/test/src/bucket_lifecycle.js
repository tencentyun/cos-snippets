// 设置存储桶生命周期
function putBucketLifecycle(assert) {
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
function getBucketLifecycle(assert) {
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
function deleteBucketLifecycle(assert) {
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

test("BucketLifecycle", async function(assert) {
  // 设置存储桶生命周期
  await putBucketLifecycle(assert)

  // 获取存储桶生命周期
  await getBucketLifecycle(assert)

  // 删除存储桶生命周期
  await deleteBucketLifecycle(assert)

//.cssg-methods-pragma
})