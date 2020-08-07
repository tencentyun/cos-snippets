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

// 高级接口拷贝对象
function transferCopyObject() {
  //.cssg-snippet-body-start:[transfer-copy-object]
  cos.sliceCopyFile({
      Bucket: 'examplebucket-1250000000',                               /* 必须 */
      Region: 'ap-beijing',                                  /* 必须 */
      Key: '1.zip',                                            /* 必须 */
      CopySource: 'test-1250000000.cos.ap-guangzhou.myqcloud.com/2.zip', /* 必须 */
      onProgress:function (progressData) {                     /* 非必须 */
          console.log(JSON.stringify(progressData));
      }
  },function (err,data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callTransferCopyObject() {
  // 高级接口拷贝对象
  transferCopyObject()

  //.cssg-methods-pragma
}