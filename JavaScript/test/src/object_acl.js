// 设置对象 ACL
function putObjectAcl(assert) {
  //.cssg-snippet-body-start:[put-object-acl]
  cos.putObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      ACL: 'public-read',        /* 非必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取对象 ACL
function getObjectAcl(assert) {
  //.cssg-snippet-body-start:[get-object-acl]
  cos.getObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("ObjectACL", async function(assert) {
  // 设置对象 ACL
  await putObjectAcl(assert)

  // 获取对象 ACL
  await getObjectAcl(assert)

//.cssg-methods-pragma
})