var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 恢复归档对象
function restoreObject() {
  //.cssg-snippet-body-start:[restore-object]
  cos.restoreObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',
      RestoreRequest: {
          Days: 1,
          CASJobParameters: {
              Tier: 'Expedited'
          }
      },
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("RestoreObject", function() {
  // 恢复归档对象
  it("restoreObject", function() {
    return restoreObject()
  })

  //.cssg-methods-pragma
})