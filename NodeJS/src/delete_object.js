var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 删除对象
function deleteObject() {
  //.cssg-snippet-body-start:[delete-object]
  cos.deleteObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject'       /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除多个对象
function deleteMultiObject() {
  //.cssg-snippet-body-start:[delete-multi-object]
  cos.deleteMultipleObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Objects: [
          {Key: 'exampleobject'},
          {Key: 'exampleobject2'},
      ]
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("DeleteObject", function() {
  // 删除对象
  it("deleteObject", function() {
    return deleteObject()
  })

  // 删除多个对象
  it("deleteMultiObject", function() {
    return deleteMultiObject()
  })

  //.cssg-methods-pragma
})