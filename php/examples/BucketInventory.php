<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketInventory
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶清单任务
    protected function putBucketInventory() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-inventory]
        try {
            $result = $cosClient->putBucketInventory(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Id' => 'string',
                'Destination' => array(
                    'COSBucketDestination'=>array(
                        'Format' => 'CSV',
                        'AccountId' => '100000000001',
                        'Bucket' => 'qcs::cos:ap-chengdu::examplebucket-1250000000',
                        'Prefix' => 'string',
                    )
                ),      
                'IsEnabled' => 'True',
                'Schedule' => array(
                    'Frequency' => 'Daily',
                ),  
                'Filter' => array(
                    'Prefix' => 'string',
                ),  
                'IncludedObjectVersions' => 'Current',
                'OptionalFields' => array(
                    'Size', 
                    'ETag',
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

    // 获取存储桶清单任务
    protected function getBucketInventory() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-inventory]
        try {
            $result = $cosClient->getBucketInvnetory(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Id' => 'string',
            ));
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        
        //.cssg-snippet-body-end
    }

    // 删除存储桶清单任务
    protected function deleteBucketInventory() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-bucket-inventory]
        try {
            $result = $cosClient->deleteBucketInvnetory(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Id' => 'string',
            ));
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
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

    public function mBucketInventory() {
        $this->init();

        // 设置存储桶清单任务
        $this->putBucketInventory();

        // 获取存储桶清单任务
        $this->getBucketInventory();

        // 删除存储桶清单任务
        $this->deleteBucketInventory();

	    //.cssg-methods-pragma
    }
}
?>