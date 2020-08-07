// 删除对象
function deleteObject(assert) {
  //.cssg-snippet-body-start:[delete-object]
  cos.deleteObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject'        /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除多个对象
function deleteMultiObject(assert) {
  //.cssg-snippet-body-start:[delete-multi-object]
  cos.deleteMultipleObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Objects: [
          {Key: 'exampleobject'},
          {Key: 'exampleobject2'},
      ]
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("DeleteObject", async function(assert) {
  // 删除对象
  await deleteObject(assert)

  // 删除多个对象
  await deleteMultiObject(assert)

//.cssg-methods-pragma
})