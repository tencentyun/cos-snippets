// 设置存储桶静态网站
function putBucketWebsite(assert) {
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
function getBucketWebsite(assert) {
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
function deleteBucketWebsite(assert) {
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

test("BucketWebsite", async function(assert) {
  // 设置存储桶静态网站
  await putBucketWebsite(assert)

  // 获取存储桶静态网站
  await getBucketWebsite(assert)

  // 删除存储桶静态网站
  await deleteBucketWebsite(assert)

//.cssg-methods-pragma
})