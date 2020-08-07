// 设置存储桶跨域规则
function putBucketCors(assert) {
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
function getBucketCors(assert) {
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
function optionObject(assert) {
  //.cssg-snippet-body-start:[option-object]
  cos.optionsObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
      Key: 'exampleobject',              /* 必须 */
      Origin: 'https://www.qq.com',      /* 必须 */
      AccessControlRequestMethod: 'PUT', /* 必须 */
      AccessControlRequestHeaders: 'origin,accept,content-type' /* 非必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶跨域规则
function deleteBucketCors(assert) {
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

test("BucketCORS", async function(assert) {
  // 设置存储桶跨域规则
  await putBucketCors(assert)

  // 获取存储桶跨域规则
  await getBucketCors(assert)

  // 实现 Object 跨域访问配置的预请求
  await optionObject(assert)

  // 删除存储桶跨域规则
  await deleteBucketCors(assert)

//.cssg-methods-pragma
})