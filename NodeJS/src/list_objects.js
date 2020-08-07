var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 获取对象列表
function getBucket() {
  //.cssg-snippet-body-start:[get-bucket]
  cos.getBucket({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',     /* 必须 */
      Prefix: 'a/',           /* 非必须 */
  }, function(err, data) {
      console.log(err || data.Contents);
  });
  
  //.cssg-snippet-body-end
}

// 获取对象列表与子目录
function getBucketWithDelimiter() {
  //.cssg-snippet-body-start:[get-bucket-with-delimiter]
  cos.getBucket({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Prefix: 'a/',              /* 非必须 */
      Delimiter: '/',            /* 非必须 */
  }, function(err, data) {
      console.log(err || data.CommonPrefixes);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("ListObjects", function() {
  // 获取对象列表
  it("getBucket", function() {
    return getBucket()
  })

  // 获取对象列表与子目录
  it("getBucketWithDelimiter", function() {
    return getBucketWithDelimiter()
  })

  //.cssg-methods-pragma
})