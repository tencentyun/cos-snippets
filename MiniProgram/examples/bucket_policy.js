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

// 设置存储桶 Policy
function putBucketPolicy() {
  //.cssg-snippet-body-start:[put-bucket-policy]
  cos.putBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Policy: {
          "version": "2.0",
          "Statement": [{
              "Effect": "allow",
              "Principal": {
                  "qcs": ["qcs::cam::uin/100000000001:uin/100000000001"]
              },
              "Action": [
                  "name/cos:PutObject",
                  "name/cos:InitiateMultipartUpload",
                  "name/cos:ListMultipartUploads",
                  "name/cos:ListParts",
                  "name/cos:UploadPart",
                  "name/cos:CompleteMultipartUpload"
              ],
              "Resource": ["qcs::cos:ap-guangzhou:uid/1250000000:examplebucket-1250000000/*"],
          }]
      },
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶 Policy
function getBucketPolicy() {
  //.cssg-snippet-body-start:[get-bucket-policy]
  cos.getBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶 Policy
function deleteBucketPolicy() {
  //.cssg-snippet-body-start:[delete-bucket-policy]
  cos.deleteBucketPolicy({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callBucketPolicy() {
  // 设置存储桶 Policy
  putBucketPolicy()

  // 获取存储桶 Policy
  getBucketPolicy()

  // 删除存储桶 Policy
  deleteBucketPolicy()

  //.cssg-methods-pragma
}