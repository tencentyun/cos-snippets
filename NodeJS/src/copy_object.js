var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 复制对象时保留对象属性
function copyObject() {
  //.cssg-snippet-body-start:[copy-object]
  cos.putObjectCopy({
      Bucket: 'examplebucket-1250000000',                               /* 必须 */
      Region: 'COS_REGION',                                  /* 必须 */
      Key: 'exampleobject',                                            /* 必须 */
      CopySource: 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject', /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("CopyObject", function() {
  // 复制对象时保留对象属性
  it("copyObject", function() {
    return copyObject()
  })

  //.cssg-methods-pragma
})