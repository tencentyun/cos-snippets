var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

// 开启存储桶日志服务
function putBucketLogging() {
  //.cssg-snippet-body-start:[put-bucket-logging]
  cos.putBucketLogging({
      Bucket: 'sourcebucket-1250000000',  /* 必须 */
      Region: 'ap-beijing',               /* 必须 */
      BucketLoggingStatus: {              /* 必须 */
          LoggingEnabled: {
              TargetBucket: 'targetbucket-1250000000',
              TargetPrefix: 'bucket-logging-prefix/'
          }
      }
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶日志服务
function getBucketLogging() {
  //.cssg-snippet-body-start:[get-bucket-logging]
  cos.getBucketLogging({
      Bucket: 'sourcebucket-1250000000',  /* 必须 */
      Region: 'ap-beijing'                /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

describe("BucketLogging", function() {
  // 开启存储桶日志服务
  it("putBucketLogging", function() {
    return putBucketLogging()
  })

  // 获取存储桶日志服务
  it("getBucketLogging", function() {
    return getBucketLogging()
  })

  //.cssg-methods-pragma
})