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

// 设置存储桶生命周期
function putBucketLifecycleArchive(assert) {
  //.cssg-snippet-body-start:[put-bucket-lifecycle-archive]
  cos.putBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Rules: [{
          "ID": "2",
          "Filter": {
              "Prefix": "dir/",
          },
          "Status": "Enabled",
          "Transition": {
              "Days": "90",
              "StorageClass": "ARCHIVE"
          }
      }],
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶生命周期
function putBucketLifecycleExpired(assert) {
  //.cssg-snippet-body-start:[put-bucket-lifecycle-expired]
  cos.putBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Rules: [{
          "ID": "3",
          "Status": "Enabled",
          "Filter": {},
          "Expiration": {
              "Days": "180"
          }
      }],
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶生命周期
function putBucketLifecycleCleanAbort(assert) {
  //.cssg-snippet-body-start:[put-bucket-lifecycle-cleanAbort]
  cos.putBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Rules: [{
          "ID": "4",
          "Status": "Enabled",
          "Filter": {},
          "AbortIncompleteMultipartUpload": {
              "DaysAfterInitiation": "30"
          }
      }],
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶生命周期
function putBucketLifecycleHistoryArchive(assert) {
  //.cssg-snippet-body-start:[put-bucket-lifecycle-historyArchive]
  cos.putBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Rules: [{
          "ID": "5",
          "Status": "Enabled",
          "Filter": {},
          "NoncurrentVersionTransition": {
              "NoncurrentDays": "30",
              "StorageClass": 'ARCHIVE'
          }
      }],
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

  // 设置存储桶生命周期
  await putBucketLifecycleArchive(assert)

  // 设置存储桶生命周期
  await putBucketLifecycleExpired(assert)

  // 设置存储桶生命周期
  await putBucketLifecycleCleanAbort(assert)

  // 设置存储桶生命周期
  await putBucketLifecycleHistoryArchive(assert)

//.cssg-methods-pragma
})