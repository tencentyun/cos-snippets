var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 获取存储桶信息
function headBucket() {
  //.cssg-snippet-body-start:[head-bucket]
  cos.headBucket({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION',
  }, function(err, data) {
      if (err) {
          console.log(err.error);
      }
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("HeadBucket", function() {
  // 获取存储桶信息
  it("headBucket", function() {
    return headBucket()
  })

  //.cssg-methods-pragma
})