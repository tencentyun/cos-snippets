// 下载对象
function getObject(assert) {
  //.cssg-snippet-body-start:[get-object]
  cos.getObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
  }, function(err, data) {
      console.log(err || data.Body);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("GetObject", async function(assert) {
  // 下载对象
  await getObject(assert)

//.cssg-methods-pragma
})