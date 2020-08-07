var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 计算签名
function getAuthorization() {
  //.cssg-snippet-body-start:[get-authorization]
  var COS = require('cos-nodejs-sdk-v5');
  var Authorization = COS.getAuthorization({
      SecretId: 'COS_SECRETID',
      SecretKey: 'COS_SECRETKEY',
      Method: 'get',
      Key: 'a.jpg',
      Expires: 60,
      Query: {},
      Headers: {}
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("GetAuthorization", function() {
  // 计算签名
  it("getAuthorization", function() {
    return getAuthorization()
  })

  //.cssg-methods-pragma
})