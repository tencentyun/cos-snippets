// 获取预签名下载链接
function getPresignDownloadUrl(assert) {
  //.cssg-snippet-body-start:[get-presign-download-url]
  var url = cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',
      Sign: false
  });
  
  //.cssg-snippet-body-end
}

// 获取预签名上传链接
function getPresignUploadUrl(assert) {
  //.cssg-snippet-body-start:[get-presign-upload-url]
  cos.getObjectUrl({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Method: 'PUT',
      Key: 'exampleobject',
      Sign: true
  }, function (err, data) {
      if (err) return console.log(err);
      console.log(data.Url);
      
      // 获取到 Url 后，前端可以这样 ajax 上传
      var xhr = new XMLHttpRequest();
      xhr.open('PUT', data.Url, true);
      xhr.onload = function (e) {
          console.log('上传成功', xhr.status, xhr.statusText);
      };
      xhr.onerror = function (e) {
          console.log('上传出错', xhr.status, xhr.statusText);
      };
      xhr.send(file); // file 是要上传的文件对象
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("ObjectPresignUrl", async function(assert) {
  // 获取预签名下载链接
  await getPresignDownloadUrl(assert)

  // 获取预签名上传链接
  await getPresignUploadUrl(assert)

//.cssg-methods-pragma
})