<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketLifecycle
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶生命周期
    protected function putBucketLifecycle() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-lifecycle]
        try {
            $result = $cosClient->putBucketLifecycle(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Rules' => array(
                    array(
                        'Expiration' => array(
                            'Days' => 1,
                        ),
                        'ID' => 'rule01',
                        'Filter' => array(
                            'Prefix' => ''
                        ),
                        'Status' => 'Enabled',
                    ),
                )
            ));
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶生命周期
    protected function getBucketLifecycle() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-lifecycle]
        try {
            $result = $cosClient->getBucketLifecycle(array(
                'Bucket' => 'examplebucket-1250000000' //格式：BucketName-APPID
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 删除存储桶生命周期
    protected function deleteBucketLifecycle() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-bucket-lifecycle]
        try {
            $result = $cosClient->deleteBucketLifecycle(array(
                'Bucket' => 'examplebucket-1250000000' //格式：BucketName-APPID
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 设置存储桶生命周期
    protected function putBucketLifecycleArchive() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-lifecycle-archive]
        try {
            $result = $cosClient->putBucketLifecycle(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Rules' => array(
                    array(
                        'ID' => 'rule01',
                        'Filter' => array(
                            'Prefix' => 'prefix01/'
                        ),  
                        'Status' => 'Enabled',
                        'Transitions' => array(
                            array(
                                'Days' => 1,
                                'StorageClass' => 'Archive'
                            ),
                        ),  
                    ),
                )
            ));  
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

	//.cssg-methods-pragma

    protected function init() {
        $secretId = "COS_SECRETID"; //"云 API 密钥 SecretId";
        $secretKey = "COS_SECRETKEY"; //"云 API 密钥 SecretKey";
        $region = "COS_REGION"; //设置一个默认的存储桶地域
        $this->cosClient = new Qcloud\Cos\Client(
            array(
                'region' => $region,
                'schema' => 'https', //协议头部，默认为http
                'credentials'=> array(
                    'secretId'  => $secretId ,
                    'secretKey' => $secretKey)));
    }

    public function mBucketLifecycle() {
        $this->init();

        // 设置存储桶生命周期
        $this->putBucketLifecycle();

        // 获取存储桶生命周期
        $this->getBucketLifecycle();

        // 删除存储桶生命周期
        $this->deleteBucketLifecycle();

        // 设置存储桶生命周期
        $this->putBucketLifecycleArchive();

	    //.cssg-methods-pragma
    }
}
?>