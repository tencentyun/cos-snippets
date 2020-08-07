// 恢复归档对象
function restoreObject(assert) {
  //.cssg-snippet-body-start:[restore-object]
  cos.restoreObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',
      RestoreRequest: {
          Days: 1,
          CASJobParameters: {
              Tier: 'Expedited'
          }
      },
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("RestoreObject", async function(assert) {
  // 恢复归档对象
  await restoreObject(assert)

//.cssg-methods-pragma
})