var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 下载对象
function getObject() {
  //.cssg-snippet-body-start:[get-object]
  cos.getObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
  }, function(err, data) {
      console.log(err || data.Body);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("GetObject", function() {
  // 下载对象
  it("getObject", function() {
    return getObject()
  })

  //.cssg-methods-pragma
})