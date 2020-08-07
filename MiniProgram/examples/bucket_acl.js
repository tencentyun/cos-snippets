var COS = require('../lib/cos-wx-sdk-v5');

var cos = new COS({
    // ForcePathStyle: true, // 如果使用了很多存储桶，可以通过打开后缀式，减少配置白名单域名数量，请求时会用地域域名
    getAuthorization: function (options, callback) {
        // 异步获取临时密钥
        wx.request({
            url: 'https://example.com/server/sts.php',
            data: {
                bucket: options.Bucket,
                region: options.Region,
            },
            dataType: 'json',
            success: function (result) {
                var data = result.data;
                var credentials = data && data.credentials;
                if (!data || !credentials) return console.error('credentials invalid');
                callback({
                    TmpSecretId: credentials.tmpSecretId,
                    TmpSecretKey: credentials.tmpSecretKey,
                    XCosSecurityToken: credentials.sessionToken,
                    // 建议返回服务器时间作为签名的开始时间，避免用户浏览器本地时间偏差过大导致签名错误
                    StartTime: data.startTime, // 时间戳，单位秒，如：1580000000
                    ExpiredTime: data.expiredTime, // 时间戳，单位秒，如：1580000900
                });
            }
        });
    }
});

// 设置存储桶 ACL
function putBucketAcl() {
  //.cssg-snippet-body-start:[put-bucket-acl]
  cos.putBucketAcl({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
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
      Region: 'ap-beijing'     /* 必须 */
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
      Region: 'ap-beijing',    /* 必须 */
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
      Region: 'ap-beijing',    /* 必须 */
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

function callBucketACL() {
  // 设置存储桶 ACL
  putBucketAcl()

  // 获取存储桶 ACL
  getBucketAcl()

  // 设置存储桶 ACL
  putBucketAclUser()

  // 设置存储桶 ACL
  putBucketAclAcp()

  //.cssg-methods-pragma
}