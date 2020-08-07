// 设置存储桶 Policy
function putBucketPolicy(assert) {
  //.cssg-snippet-body-start:[put-bucket-policy]
  cos.putBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Policy: {
          "version": "2.0",
          "Statement": [{
              "Effect": "allow",
              "Principal": {
                  "qcs": ["qcs::cam::uin/100000000001:uin/100000000001"]
              },
              "Action": [
                  "name/cos:PutObject",
                  "name/cos:InitiateMultipartUpload",
                  "name/cos:ListMultipartUploads",
                  "name/cos:ListParts",
                  "name/cos:UploadPart",
                  "name/cos:CompleteMultipartUpload"
              ],
              "Resource": ["qcs::cos:ap-guangzhou:uid/1250000000:examplebucket-1250000000/*"],
          }]
      },
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 Policy
function getBucketPolicy(assert) {
  //.cssg-snippet-body-start:[get-bucket-policy]
  cos.getBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶 Policy
function deleteBucketPolicy(assert) {
  //.cssg-snippet-body-start:[delete-bucket-policy]
  cos.deleteBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("BucketPolicy", async function(assert) {
  // 设置存储桶 Policy
  await putBucketPolicy(assert)

  // 获取存储桶 Policy
  await getBucketPolicy(assert)

  // 删除存储桶 Policy
  await deleteBucketPolicy(assert)

//.cssg-methods-pragma
})