var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 创建存储桶
function putBucket() {
  //.cssg-snippet-body-start:[put-bucket]
  cos.putBucket({
      Bucket: 'examplebucket-1250000000',
      Region: 'COS_REGION'
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("PutBucket", function() {
  // 创建存储桶
  it("putBucket", function() {
    return putBucket()
  })

  //.cssg-methods-pragma
})