var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置对象 ACL
function putObjectAcl() {
  //.cssg-snippet-body-start:[put-object-acl]
  cos.putObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      ACL: 'public-read',        /* 非必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取对象 ACL
function getObjectAcl() {
  //.cssg-snippet-body-start:[get-object-acl]
  cos.getObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置对象 ACL
function putObjectAclUser() {
  //.cssg-snippet-body-start:[put-object-acl-user]
  cos.putObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      GrantFullControl: 'id="100000000001"' // 100000000001是主账号 uin
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置对象 ACL
function putObjectAclAcp() {
  //.cssg-snippet-body-start:[put-object-acl-acp]
  cos.putObjectAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
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

describe("ObjectACL", function() {
  // 设置对象 ACL
  it("putObjectAcl", function() {
    return putObjectAcl()
  })

  // 获取对象 ACL
  it("getObjectAcl", function() {
    return getObjectAcl()
  })

  // 设置对象 ACL
  it("putObjectAclUser", function() {
    return putObjectAclUser()
  })

  // 设置对象 ACL
  it("putObjectAclAcp", function() {
    return putObjectAclAcp()
  })

  //.cssg-methods-pragma
})