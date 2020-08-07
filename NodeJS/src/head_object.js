var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 获取对象信息
function headObject() {
  //.cssg-snippet-body-start:[head-object]
  cos.headObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',               /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("HeadObject", function() {
  // 获取对象信息
  it("headObject", function() {
    return headObject()
  })

  //.cssg-methods-pragma
})