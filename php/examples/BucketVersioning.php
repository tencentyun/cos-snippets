<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketVersioning
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶多版本
    protected function putBucketVersioning() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-versioning]
        try {
            $result = $cosClient->putBucketVersioning(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Status' => 'Enabled'
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶多版本状态
    protected function getBucketVersioning() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-versioning]
        try {
            $result = $cosClient->getBucketVersioning(array(
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

    public function mBucketVersioning() {
        $this->init();

        // 设置存储桶多版本
        $this->putBucketVersioning();

        // 获取存储桶多版本状态
        $this->getBucketVersioning();

	    //.cssg-methods-pragma
    }
}
?>