var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 获取预签名下载链接
function getPresignDownloadUrl() {
  //.cssg-snippet-body-start:[get-presign-download-url]
  var url = cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',
      Key: '1.jpg'
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名上传链接
function getPresignUploadUrl() {
  //.cssg-snippet-body-start:[get-presign-upload-url]
  var request = require('request');
  var fs = require('fs');
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',
      Method: 'PUT',
      Key: '1.jpg',
      Sign: true
  }, function (err, data) {
      if (err) return console.log(err);
      console.log(data.Url);
      var readStream = fs.createReadStream(__dirname + '/1.jpg');
      var req = request({
          method: 'PUT',
          url: data.Url,
      }, function (err, response, body) {
          console.log(err || body);
      });
      readStream.pipe(req);
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名下载链接
function getPresignDownloadUrlNosign() {
  //.cssg-snippet-body-start:[get-presign-download-url-nosign]
  var url = cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',
      Key: '1.jpg',
      Sign: false
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名下载链接
function getPresignDownloadUrlCallback() {
  //.cssg-snippet-body-start:[get-presign-download-url-callback]
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',
      Key: '1.jpg',
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
      Region: 'COS_REGION',
      Key: '1.jpg',
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
  var request = require('request');
  var fs = require('fs');
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',
      Key: '1.jpg',
      Sign: true
  }, function (err, data) {
      if (err) return console.log(err);
      console.log(data.Url);
      var req = request(data.Url, function (err, response, body) {
          console.log(err || body);
      });
      var writeStream = fs.createWriteStream(__dirname + '/1.jpg');
      req.pipe(writeStream);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("ObjectPresignUrl", function() {
  // 获取预签名下载链接
  it("getPresignDownloadUrl", function() {
    return getPresignDownloadUrl()
  })

  // 获取预签名上传链接
  it("getPresignUploadUrl", function() {
    return getPresignUploadUrl()
  })

  // 获取预签名下载链接
  it("getPresignDownloadUrlNosign", function() {
    return getPresignDownloadUrlNosign()
  })

  // 获取预签名下载链接
  it("getPresignDownloadUrlCallback", function() {
    return getPresignDownloadUrlCallback()
  })

  // 获取预签名下载链接
  it("getPresignDownloadUrlExpiration", function() {
    return getPresignDownloadUrlExpiration()
  })

  // 获取预签名下载链接
  it("getPresignDownloadUrlThenFetch", function() {
    return getPresignDownloadUrlThenFetch()
  })

  //.cssg-methods-pragma
})