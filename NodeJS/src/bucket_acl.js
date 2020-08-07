var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶 ACL
function putBucketAcl() {
  //.cssg-snippet-body-start:[put-bucket-acl]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      ACL: 'public-read'
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 ACL
function getBucketAcl() {
  //.cssg-snippet-body-start:[get-bucket-acl]
  cos.getBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION'     /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶 ACL
function putBucketAclUser() {
  //.cssg-snippet-body-start:[put-bucket-acl-user]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      GrantFullControl: 'id="qcs::cam::uin/100000000001:uin/100000000001",id="qcs::cam::uin/100000000011:uin/100000000011"' // 100000000001是 uin
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶 ACL
function putBucketAclAcp() {
  //.cssg-snippet-body-start:[put-bucket-acl-acp]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      AccessControlPolicy: {
          "Owner": { // AccessControlPolicy 里必须有 owner
              "ID": 'qcs::cam::uin/100000000001:uin/100000000001' // 100000000001 是 Bucket 所属用户的 Uin
          },
          "Grants": [{
              "Grantee": {
                  "ID": "qcs::cam::uin/100000000011:uin/100000000011", // 100000000011 是 Uin
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

describe("BucketACL", function() {
  // 设置存储桶 ACL
  it("putBucketAcl", function() {
    return putBucketAcl()
  })

  // 获取存储桶 ACL
  it("getBucketAcl", function() {
    return getBucketAcl()
  })

  // 设置存储桶 ACL
  it("putBucketAclUser", function() {
    return putBucketAclUser()
  })

  // 设置存储桶 ACL
  it("putBucketAclAcp", function() {
    return putBucketAclAcp()
  })

  //.cssg-methods-pragma
})