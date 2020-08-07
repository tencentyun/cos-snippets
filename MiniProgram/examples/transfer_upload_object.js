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

// 上传暂停
function transferUploadPause() {
  //.cssg-snippet-body-start:[transfer-upload-pause]
  var taskId = 'xxxxx';                   /* 必须 */
  cos.pauseTask(taskId);
  
  //.cssg-snippet-body-end
}

// 上传续传
function transferUploadResume() {
  //.cssg-snippet-body-start:[transfer-upload-resume]
  var taskId = 'xxxxx';                   /* 必须 */
  cos.restartTask(taskId);
  
  //.cssg-snippet-body-end
}

// 上传取消
function transferUploadCancel() {
  //.cssg-snippet-body-start:[transfer-upload-cancel]
  var taskId = 'xxxxx';                   /* 必须 */
  cos.cancelTask(taskId);
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callTransferUploadObject() {
  // 上传暂停
  transferUploadPause()

  // 上传续传
  transferUploadResume()

  // 上传取消
  transferUploadCancel()

  //.cssg-methods-pragma
}