var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 高级接口拷贝对象
function transferCopyObject() {
  //.cssg-snippet-body-start:[transfer-copy-object]
  cos.sliceCopyFile({
      Bucket: 'examplebucket-1250000000',                               /* 必须 */
      Region: 'COS_REGION',                                  /* 必须 */
      Key: 'exampleobject',                                            /* 必须 */
      CopySource: 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject', /* 必须 */
      onProgress:function (progressData) {                     /* 非必须 */
          console.log(JSON.stringify(progressData));
      }
  },function (err,data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("TransferCopyObject", function() {
  // 高级接口拷贝对象
  it("transferCopyObject", function() {
    return transferCopyObject()
  })

  //.cssg-methods-pragma
})