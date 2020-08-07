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

// 下载对象
function getObjectRange() {
  //.cssg-snippet-body-start:[get-object-range]
  cos.getObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      Range: 'bytes=1-3',        /* 非必须 */
  }, function(err, data) {
      console.log(err || data.Body);
  });
  
  //.cssg-snippet-body-end
}

// 下载对象
function getObjectPath() {
  //.cssg-snippet-body-start:[get-object-path]
  cos.getObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      Output: './exampleobject',
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 下载对象
function getObjectStream() {
  //.cssg-snippet-body-start:[get-object-stream]
  cos.getObject({
      Bucket: 'examplebucket-1250000000', /* 必须 */
      Region: 'COS_REGION',    /* 必须 */
      Key: 'exampleobject',              /* 必须 */
      Output: fs.createWriteStream('./exampleobject'),
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("GetObject", function() {
  // 下载对象
  it("getObject", function() {
    return getObject()
  })

  // 下载对象
  it("getObjectRange", function() {
    return getObjectRange()
  })

  // 下载对象
  it("getObjectPath", function() {
    return getObjectPath()
  })

  // 下载对象
  it("getObjectStream", function() {
    return getObjectStream()
  })

  //.cssg-methods-pragma
})