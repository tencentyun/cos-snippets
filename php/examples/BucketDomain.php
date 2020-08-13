<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketDomain
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶自定义域名
    protected function putBucketDomain() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-domain]
        try {
            $result = $cosClient->putBucketDomain(array( 
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID 
                'DomainRules' => array( 
                    array( 
                        'Name' => 'www.qq.com', 
                        'Status' => 'ENABLED', 
                        'Type' => 'REST', 
                        'ForcedReplacement' => 'CNAME', 
                    ),  
                    // ... repeated 
                ),  
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶自定义域名
    protected function getBucketDomain() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-domain]
        try {
            $result = $cosClient->getBucketDomain(array( 
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
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

    public function mBucketDomain() {
        $this->init();

        // 设置存储桶自定义域名
        $this->putBucketDomain();

        // 获取存储桶自定义域名
        $this->getBucketDomain();

	    //.cssg-methods-pragma
    }
}
?>