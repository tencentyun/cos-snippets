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

// 设置对象 ACL
function putObjectAclUser(assert) {
  //.cssg-snippet-body-start:[put-object-acl-user]
  cos.putObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      GrantFullControl: 'id="100000000001"' // 100000000001是主账号 uin
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置对象 ACL
function putObjectAclAcp(assert) {
  //.cssg-snippet-body-start:[put-object-acl-acp]
  cos.putObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      AccessControlPolicy: {
          "Owner": { // AccessControlPolicy 里必须有 owner
              "ID": 'qcs::cam::uin/100000000001:uin/100000000001' // 100000000001 是 Bucket 所属用户的 QQ 号
          },
          "Grants": [{
              "Grantee": {
                  "ID": "qcs::cam::uin/100000000011:uin/100000000011", // 100000000011 是 QQ 号
              },
              "Permission": "WRITE"
          }]
      }
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

  // 设置对象 ACL
  await putObjectAclUser(assert)

  // 设置对象 ACL
  await putObjectAclAcp(assert)

//.cssg-methods-pragma
})