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

// 获取预签名下载链接
function getPresignDownloadUrl() {
  //.cssg-snippet-body-start:[get-presign-download-url]
  var url = cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'ap-beijing',
      Key: 'picture.jpg'
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名下载链接
function getPresignDownloadUrlNosign() {
  //.cssg-snippet-body-start:[get-presign-download-url-nosign]
  var url = cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'ap-beijing',
      Key: 'picture.jpg',
      Sign: false
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名下载链接
function getPresignDownloadUrlCallback() {
  //.cssg-snippet-body-start:[get-presign-download-url-callback]
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'ap-beijing',
      Key: 'picture.jpg',
      Sign: false
  }, function (err, data) {
      console.log(err || data.Url);
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名下载链接
function getPresignDownloadUrlExpiration() {
  //.cssg-snippet-body-start:[get-presign-download-url-expiration]
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'ap-beijing',
      Key: 'picture.jpg',
      Sign: true,
      Expires: 3600, // 单位秒
  }, function (err, data) {
      console.log(err || data.Url);
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名下载链接
function getPresignDownloadUrlThenFetch() {
  //.cssg-snippet-body-start:[get-presign-download-url-then-fetch]
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'ap-beijing',
      Key: 'picture.jpg',
      Sign: true
  }, function (err, data) {
      if (!err) return console.log(err);
      wx.downloadFile({
          url: data.Url, // 需要加 url 的域名作为下载白名单
          success (res) {
              console.log(res.statusCode, res.tempFilePath);
          },
          fail: function (err) {
              console.log(err);
          },
      });
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callObjectPresignUrl() {
  // 获取预签名下载链接
  getPresignDownloadUrl()

  // 获取预签名下载链接
  getPresignDownloadUrlNosign()

  // 获取预签名下载链接
  getPresignDownloadUrlCallback()

  // 获取预签名下载链接
  getPresignDownloadUrlExpiration()

  // 获取预签名下载链接
  getPresignDownloadUrlThenFetch()

  //.cssg-methods-pragma
}