var COS = require('../lib/cos-wx-sdk-v5');

var cos = new COS({
    // ForcePathStyle: true, // 如果使用了很多存储桶，可以通过打开后缀式，减少配置白名单域名数量，请求时会用地域域名
    getAuthorization: function (options, callback) {
        // 异步获取临时密钥
        wx.request({
            url: 'https://example.com/server/sts.php',
            data: {
                bucket: options.Bucket,
                region: options.Region,
            },
            dataType: 'json',
            success: function (result) {
                var data = result.data;
                var credentials = data && data.credentials;
                if (!data || !credentials) return console.error('credentials invalid');
                callback({
                    TmpSecretId: credentials.tmpSecretId,
                    TmpSecretKey: credentials.tmpSecretKey,
                    XCosSecurityToken: credentials.sessionToken,
                    // 建议返回服务器时间作为签名的开始时间，避免用户浏览器本地时间偏差过大导致签名错误
                    StartTime: data.startTime, // 时间戳，单位秒，如：1580000000
                    ExpiredTime: data.expiredTime, // 时间戳，单位秒，如：1580000900
                });
            }
        });
    }
});

// 设置存储桶清单任务
function putBucketInventory() {
  //.cssg-snippet-body-start:[put-bucket-inventory]
  cos.putBucketInventory({
      Bucket: 'sourcebucket-1250000000',  /* 必须 */
      Region: 'ap-beijing',               /* 必须 */
      Id: 'inventory_test',               /* 必须 */
      InventoryConfiguration: {
          Id: 'inventory_test',
          IsEnabled: 'true',
          Destination: {
              COSBucketDestination: {
                  Format: 'CSV',
                  AccountId: '100000000001',
                  Bucket: 'qcs::cos:ap-beijing::targetbucket-1250000000',
                  Prefix: 'inventory_test_prefix',
                  Encryption: {
                      SSECOS: ''
                  }
              }
          },
          Schedule: {
              Frequency: 'Daily'
          },
          Filter: {
              Prefix: 'filter_prefix'
          },
          IncludedObjectVersions: 'All',
          OptionalFields: [
              'Size',
              'LastModifiedDate',
              'StorageClass',
              'ETag'
          ]
      }
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 获取存储桶清单任务
function getBucketInventory() {
  //.cssg-snippet-body-start:[get-bucket-inventory]
  cos.getBucketInventory({
      Bucket: 'sourcebucket-1250000000',  /* 必须 */
      Region: 'ap-beijing',               /* 必须 */
      Id: 'inventory_test'                /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

// 删除存储桶清单任务
function deleteBucketInventory() {
  //.cssg-snippet-body-start:[delete-bucket-inventory]
  cos.deleteBucketInventory({
      Bucket: 'sourcebucket-1250000000',  /* 必须 */
      Region: 'ap-beijing',               /* 必须 */
      Id: 'inventory_test'                /* 必须 */
  }, function(err, data) {
      console.log(err || data);
  });
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma

function callBucketInventory() {
  // 设置存储桶清单任务
  putBucketInventory()

  // 获取存储桶清单任务
  getBucketInventory()

  // 删除存储桶清单任务
  deleteBucketInventory()

  //.cssg-methods-pragma
}