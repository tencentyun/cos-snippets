const { test } = QUnit;

const createFile = function (options) {
  var buffer = new ArrayBuffer(options.size || 0);
  var arr = new Uint8Array(buffer);
  for (var i = 0; i < arr.length; i++) {
      arr[i] = 0;
  }
  var opt = {};
  options.type && (opt.type = options.type);
  var blob = new Blob([buffer], options);
  return blob;
}

var uploadId
var eTag
const fileObject = createFile({size: 2048})

function initCOS () {
  var cos = new COS(cosKey);
  
  return cos
}

const bucket = 'bucket-cssg-test-js-1253653367'
const region = 'ap-guangzhou'

function suspendBucketVersioning(assert) {
  return new Promise((resolve, reject) => {
    cos.putBucketVersioning({
        Bucket: bucket,  /* 必须 */
        Region: region,     /* 存储桶所在地域，必须字段 */
        VersioningConfiguration: {
            Status: "Suspended"
        }
    }, function (err, data) {
        assert.notOk(err)
        resolve(data)
        console.log(err || data);
    });
    
  })
}

function cleanupObjects(assert) {
  return new Promise((resolve, reject) => {
    cos.deleteObject({
      Bucket: bucket, /* 必须 */
      Region: region,    /* 必须 */
      Key: 'object4js',       /* 必须 */
      VersionId: 'null'
    }, function(err, data) {
      cos.deleteObject({
          Bucket: bucket, /* 必须 */
          Region: region,    /* 必须 */
          Key: 'object4js2',       /* 必须 */
          VersionId: 'null'
      }, function(err, data) {
          console.log(err || data);
          cos.deleteObject({
            Bucket: bucket, /* 必须 */
            Region: region,    /* 必须 */
            Key: 'a/',       /* 必须 */
            VersionId: 'null'
        }, function(err, data) {
            console.log(err || data);
            assert.notOk(err)
            resolve(data)
        });
      });
    })
  })
}

function sleepfor(millseconds) {
  return new Promise((resolve, reject) => {
    setTimeout(millseconds, function() {
      resolve()
    })
  })
}

var cos = initCOS()



