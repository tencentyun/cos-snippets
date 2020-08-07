var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
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
      Region: 'COS_REGION',    /* 必须 */
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

describe("BucketCORS", function() {
  // 设置存储桶跨域规则
  it("putBucketCors", function() {
    return putBucketCors()
  })

  // 获取存储桶跨域规则
  it("getBucketCors", function() {
    return getBucketCors()
  })

  // 实现 Object 跨域访问配置的预请求
  it("optionObject", function() {
    return optionObject()
  })

  // 删除存储桶跨域规则
  it("deleteBucketCors", function() {
    return deleteBucketCors()
  })

  //.cssg-methods-pragma
})