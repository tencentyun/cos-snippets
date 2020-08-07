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

// 设置存储桶生命周期
function putBucketLifecycle() {
  //.cssg-snippet-body-start:[put-bucket-lifecycle]
  cos.putBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Rules: [{
          "ID": "1",
          "Status": "Enabled",
          "Filter": {},
          "Transition": {
              "Days": "30",
              "StorageClass": "STANDARD_IA"
          }
      }],
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶生命周期
function getBucketLifecycle() {
  //.cssg-snippet-body-start:[get-bucket-lifecycle]
  cos.getBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶生命周期
function deleteBucketLifecycle() {
  //.cssg-snippet-body-start:[delete-bucket-lifecycle]
  cos.deleteBucketLifecycle({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callBucketLifecycle() {
  // 设置存储桶生命周期
  putBucketLifecycle()

  // 获取存储桶生命周期
  getBucketLifecycle()

  // 删除存储桶生命周期
  deleteBucketLifecycle()

  //.cssg-methods-pragma
}