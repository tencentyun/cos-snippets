// 设置存储桶 ACL
function putBucketAcl(assert) {
  //.cssg-snippet-body-start:[put-bucket-acl]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      ACL: 'public-read'
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 ACL
function getBucketAcl(assert) {
  //.cssg-snippet-body-start:[get-bucket-acl]
  cos.getBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶 ACL
function putBucketAclUser(assert) {
  //.cssg-snippet-body-start:[put-bucket-acl-user]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      GrantFullControl: 'id="qcs::cam::uin/100000000001:uin/100000000001",id="qcs::cam::uin/100000000011:uin/100000000011"' // 100000000001是 uin
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 设置存储桶 ACL
function putBucketAclAcp(assert) {
  //.cssg-snippet-body-start:[put-bucket-acl-acp]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
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

test("BucketACL", async function(assert) {
  // 设置存储桶 ACL
  await putBucketAcl(assert)

  // 获取存储桶 ACL
  await getBucketAcl(assert)

  // 设置存储桶 ACL
  await putBucketAclUser(assert)

  // 设置存储桶 ACL
  await putBucketAclAcp(assert)

//.cssg-methods-pragma
})