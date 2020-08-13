<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketCORS
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶跨域规则
    protected function putBucketCors() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-cors]
        try {
            $result = $cosClient->putBucketCors(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'CORSRules' => array(
                    array(
                        'AllowedHeaders' => array('*',),
                        'AllowedMethods' => array('PUT', ),
                        'AllowedOrigins' => array('*', ),
                        'ExposeHeaders' => array('*', ),
                        'MaxAgeSeconds' => 1,
                    ),  
                    // ... repeated
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

    // 获取存储桶跨域规则
    protected function getBucketCors() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-cors]
        try {
            $result = $cosClient->getBucketCors(array(
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

    // 删除存储桶跨域规则
    protected function deleteBucketCors() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-bucket-cors]
        try {
            $result = $cosClient->deleteBucketCors(array(
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

    public function mBucketCORS() {
        $this->init();

        // 设置存储桶跨域规则
        $this->putBucketCors();

        // 获取存储桶跨域规则
        $this->getBucketCors();

        // 删除存储桶跨域规则
        $this->deleteBucketCors();

	    //.cssg-methods-pragma
    }
}
?>