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

// 设置存储桶跨域规则
function putBucketCors() {
  //.cssg-snippet-body-start:[put-bucket-cors]
  cos.putBucketCors({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      CORSRules: [{
          "AllowedOrigin": ["*"],
          "AllowedMethod": ["GET", "POST", "PUT", "DELETE", "HEAD"],
          "AllowedHeader": ["*"],
          "ExposeHeader": ["ETag", "x-cos-acl", "x-cos-version-id", "x-cos-delete-marker", "x-cos-server-side-encryption"],
          "MaxAgeSeconds": "5"
      }]
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶跨域规则
function getBucketCors() {
  //.cssg-snippet-body-start:[get-bucket-cors]
  cos.getBucketCors({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 实现 Object 跨域访问配置的预请求
function optionObject() {
  //.cssg-snippet-body-start:[option-object]
  cos.optionsObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
      Key: 'picture.jpg',              /* 必须 */
      Origin: 'https://www.qq.com',      /* 必须 */
      AccessControlRequestMethod: 'PUT', /* 必须 */
      AccessControlRequestHeaders: 'origin,accept,content-type' /* 非必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶跨域规则
function deleteBucketCors() {
  //.cssg-snippet-body-start:[delete-bucket-cors]
  cos.deleteBucketCors({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callBucketCORS() {
  // 设置存储桶跨域规则
  putBucketCors()

  // 获取存储桶跨域规则
  getBucketCors()

  // 实现 Object 跨域访问配置的预请求
  optionObject()

  // 删除存储桶跨域规则
  deleteBucketCors()

  //.cssg-methods-pragma
}