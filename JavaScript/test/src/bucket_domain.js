// 设置存储桶自定义域名
function putBucketDomain(assert) {
  //.cssg-snippet-body-start:[put-bucket-domain]
  cos.putBucketDomain({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
      DomainRule: [{
          Status: "DISABLED",
          Name: "www.example.com",
          Type: "REST"
      },
      {
          Status: "DISABLED",
          Name: "www.example.net",
          Type: "WEBSITE",
      }]
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶自定义域名
function getBucketDomain(assert) {
  //.cssg-snippet-body-start:[get-bucket-domain]
  cos.getBucketDomain({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'ap-beijing',    /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("BucketDomain", async function(assert) {
  // 设置存储桶自定义域名
  await putBucketDomain(assert)

  // 获取存储桶自定义域名
  await getBucketDomain(assert)

//.cssg-methods-pragma
})