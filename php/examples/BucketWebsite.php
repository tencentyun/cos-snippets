<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketWebsite
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶静态网站
    protected function putBucketWebsite() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-website]
        try {
            $result = $cosClient->putBucketWebsite(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'IndexDocument' => array(
                    'Suffix' => 'index.html',
                ),
                'RedirectAllRequestsTo' => array(
                    'Protocol' => 'https',
                ),
                'ErrorDocument' => array(
                    'Key' => 'Error.html',
                ),
                'RoutingRules' => array(
                    array(
                        'Condition' => array(
                            'HttpErrorCodeReturnedEquals' => '405',
                        ),
                        'Redirect' => array(
                            'Protocol' => 'https',
                            'ReplaceKeyWith' => '404.html',
                        ),
                    ),  
                    // ... repeated
                ),  
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶静态网站
    protected function getBucketWebsite() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-website]
        try {
            $result = $cosClient->getBucketWebsite(array(
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

    // 删除存储桶静态网站
    protected function deleteBucketWebsite() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-bucket-website]
        try {
            $result = $cosClient->deleteBucketWebsite(array(
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

    public function mBucketWebsite() {
        $this->init();

        // 设置存储桶静态网站
        $this->putBucketWebsite();

        // 获取存储桶静态网站
        $this->getBucketWebsite();

        // 删除存储桶静态网站
        $this->deleteBucketWebsite();

	    //.cssg-methods-pragma
    }
}
?>