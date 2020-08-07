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

// 设置存储桶跨地域复制规则
function putBucketReplication() {
  //.cssg-snippet-body-start:[put-bucket-replication]
  cos.putBucketReplication({
      Bucket: 'examplebucket-1250000000',  /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      ReplicationConfiguration: { /* 必须 */
          Role: "qcs::cam::uin/100000000001:uin/100000000001",
          Rules: [{
              ID: "1",
              Status: "Enabled",
              Prefix: "sync/",
              Destination: {
                  Bucket: "qcs::cos:ap-beijing::destinationbucket-1250000000",
                  StorageClass: "Standard",
              }
          }]
      }
  }, function (err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶跨地域复制规则
function getBucketReplication() {
  //.cssg-snippet-body-start:[get-bucket-replication]
  cos.getBucketReplication({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶跨地域复制规则
function deleteBucketReplication() {
  //.cssg-snippet-body-start:[delete-bucket-replication]
  cos.deleteBucketReplication({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callBucketReplication() {
  // 设置存储桶跨地域复制规则
  putBucketReplication()

  // 获取存储桶跨地域复制规则
  getBucketReplication()

  // 删除存储桶跨地域复制规则
  deleteBucketReplication()

  //.cssg-methods-pragma
}