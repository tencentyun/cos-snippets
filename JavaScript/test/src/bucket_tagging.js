// 设置存储桶标签
function putBucketTagging(assert) {
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
function getBucketTagging(assert) {
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
function deleteBucketTagging(assert) {
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

test("BucketTagging", async function(assert) {
  // 设置存储桶标签
  await putBucketTagging(assert)

  // 获取存储桶标签
  await getBucketTagging(assert)

  // 删除存储桶标签
  await deleteBucketTagging(assert)

//.cssg-methods-pragma
})