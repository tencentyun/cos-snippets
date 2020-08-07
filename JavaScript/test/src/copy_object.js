// 复制对象时保留对象属性
function copyObject(assert) {
  //.cssg-snippet-body-start:[copy-object]
  cos.putObjectCopy({
      Bucket: 'examplebucket-1250000000',                               /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',                                            /* 必须 */
      CopySource: 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject', /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("CopyObject", async function(assert) {
  // 复制对象时保留对象属性
  await copyObject(assert)

//.cssg-methods-pragma
})