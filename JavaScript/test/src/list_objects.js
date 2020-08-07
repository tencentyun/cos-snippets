// 获取对象列表
function getBucket(assert) {
  //.cssg-snippet-body-start:[get-bucket]
  cos.getBucket({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Prefix: 'a/',           /* 非必须 */
  }, function(err, data) {
      console.log(err || data.Contents);
  });
  
  //.cssg-snippet-body-end
}

// 获取对象列表与子目录
function getBucketWithDelimiter(assert) {
  //.cssg-snippet-body-start:[get-bucket-with-delimiter]
  cos.getBucket({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Prefix: 'a/',              /* 非必须 */
      Delimiter: '/',            /* 非必须 */
  }, function(err, data) {
      console.log(err || data.CommonPrefixes);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("ListObjects", async function(assert) {
  // 获取对象列表
  await getBucket(assert)

  // 获取对象列表与子目录
  await getBucketWithDelimiter(assert)

//.cssg-methods-pragma
})