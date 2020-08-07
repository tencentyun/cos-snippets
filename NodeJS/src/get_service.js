var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 获取存储桶列表
function getService() {
  //.cssg-snippet-body-start:[get-service]
  cos.getService(function (err, data) {
      console.log(data && data.Buckets);
  });
  
  //.cssg-snippet-body-end
}

// 获取地域的存储桶列表
function getRegionalService() {
  //.cssg-snippet-body-start:[get-regional-service]
  cos.getService({
      Region: 'COS_REGION',
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

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

describe("GetService", function() {
  // 获取存储桶列表
  it("getService", function() {
    return getService()
  })

  // 获取地域的存储桶列表
  it("getRegionalService", function() {
    return getRegionalService()
  })

  // 计算签名
  it("getAuthorization", function() {
    return getAuthorization()
  })

  //.cssg-methods-pragma
})