var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
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

describe("BucketInventory", function() {
  // 设置存储桶清单任务
  it("putBucketInventory", function() {
    return putBucketInventory()
  })

  // 获取存储桶清单任务
  it("getBucketInventory", function() {
    return getBucketInventory()
  })

  // 删除存储桶清单任务
  it("deleteBucketInventory", function() {
    return deleteBucketInventory()
  })

  //.cssg-methods-pragma
})