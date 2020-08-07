// 获取存储桶信息
function headBucket(assert) {
  //.cssg-snippet-body-start:[head-bucket]
  cos.headBucket({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      if (err) {
          console.log(err.error);
      }
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("HeadBucket", async function(assert) {
  // 获取存储桶信息
  await headBucket(assert)

//.cssg-methods-pragma
})