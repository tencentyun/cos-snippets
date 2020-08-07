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

// 设置存储桶多版本
function putBucketVersioning() {
  //.cssg-snippet-body-start:[put-bucket-versioning]
  cos.putBucketVersioning({
      Bucket: 'examplebucket-1250000000',  /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      VersioningConfiguration: {
          Status: "Enabled"
      }
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶多版本状态
function getBucketVersioning() {
  //.cssg-snippet-body-start:[get-bucket-versioning]
  cos.getBucketVersioning({
      Bucket: 'examplebucket-1250000000',  /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callBucketVersioning() {
  // 设置存储桶多版本
  putBucketVersioning()

  // 获取存储桶多版本状态
  getBucketVersioning()

  //.cssg-methods-pragma
}