// 计算签名
function getAuthorization(assert) {
  //.cssg-snippet-body-start:[get-authorization]
  var Authorization = COS.getAuthorization({
      SecretId: 'COS_SECRETID',
      SecretKey: 'COS_SECRETKEY',
      Method: 'get',
      Key: 'exampleobject',
      Expires: 60,
      Query: {},
      Headers: {}
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

test("GetAuthorization", async function(assert) {
  // 计算签名
  await getAuthorization(assert)

//.cssg-methods-pragma
})