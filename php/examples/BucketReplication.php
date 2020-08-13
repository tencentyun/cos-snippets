<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketReplication
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶跨地域复制规则
    protected function putBucketReplication() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-replication]
        try {
            $result = $cosClient->putBucketReplication(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Role' => 'qcs::cam::uin/100000000001:uin/100000000001',
                'Rules'=>array(
                    array(
                        'Status' => 'Enabled',
                        'ID' => 'string',
                        'Prefix' => 'string',
                        'Destination' => array(                    
                            'Bucket' => 'qcs::cos:ap-beijing::destinationbucket-1250000000',
                            'StorageClass' => 'standard',                
                        ),  
                        // ...repeated            ),  
                ),      
            ))); 
            // 请求成功    print_r($result);
        } catch (\Exception $e) {    // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶跨地域复制规则
    protected function getBucketReplication() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-replication]
        try {
            $result = $cosClient->getBucketReplication(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

    // 删除存储桶跨地域复制规则
    protected function deleteBucketReplication() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-bucket-replication]
        try {
            $result = $cosClient->deleteBucketReplication(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
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

    public function mBucketReplication() {
        $this->init();

        // 设置存储桶跨地域复制规则
        $this->putBucketReplication();

        // 获取存储桶跨地域复制规则
        $this->getBucketReplication();

        // 删除存储桶跨地域复制规则
        $this->deleteBucketReplication();

	    //.cssg-methods-pragma
    }
}
?>