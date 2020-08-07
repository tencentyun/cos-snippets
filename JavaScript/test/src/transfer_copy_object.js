// 高级接口拷贝对象
function transferCopyObject(assert) {
  //.cssg-snippet-body-start:[transfer-copy-object]
  cos.sliceCopyFile({
      Bucket: 'examplebucket-1250000000',                               /* 必须 */
      Region: 'COS_REGION',     /* 存储桶所在地域，必须字段 */
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

test("TransferCopyObject", async function(assert) {
  // 高级接口拷贝对象
  await transferCopyObject(assert)

//.cssg-methods-pragma
})