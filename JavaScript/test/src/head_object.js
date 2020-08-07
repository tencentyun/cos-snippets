// 获取对象信息
function headObject(assert) {
  //.cssg-snippet-body-start:[head-object]
  cos.headObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',               /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("HeadObject", async function(assert) {
  // 获取对象信息
  await headObject(assert)

//.cssg-methods-pragma
})