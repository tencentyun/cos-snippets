var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 设置存储桶静态网站
function putBucketWebsite() {
  //.cssg-snippet-body-start:[put-bucket-website]
  cos.putBucketWebsite({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
      WebsiteConfiguration: {
          IndexDocument: {
              Suffix: "index.html"
          },
          ErrorDocument: {
              Key: "error.html"
          },
          RedirectAllRequestsTo: {
              Protocol: "https"
          },
      }
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶静态网站
function getBucketWebsite() {
  //.cssg-snippet-body-start:[get-bucket-website]
  cos.getBucketWebsite({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶静态网站
function deleteBucketWebsite() {
  //.cssg-snippet-body-start:[delete-bucket-website]
  cos.deleteBucketWebsite({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketWebsite", function() {
  // 设置存储桶静态网站
  it("putBucketWebsite", function() {
    return putBucketWebsite()
  })

  // 获取存储桶静态网站
  it("getBucketWebsite", function() {
    return getBucketWebsite()
  })

  // 删除存储桶静态网站
  it("deleteBucketWebsite", function() {
    return deleteBucketWebsite()
  })

  //.cssg-methods-pragma
})