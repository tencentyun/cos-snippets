<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketTagging
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶标签
    protected function putBucketTagging() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-tagging]
        try {
            $result = $cosClient->putBucketTagging(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'TagSet' => array(
                    array('Key'=>'key1',
                          'Value'=>'value1',
                    ),  
                    array('Key'=>'key2',
                          'Value'=>'value2',
                    ),  
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

    // 获取存储桶标签
    protected function getBucketTagging() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-tagging]
        try {
            $result = $cosClient->getBucketTagging(array(
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

    // 删除存储桶标签
    protected function deleteBucketTagging() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-bucket-tagging]
        try {
            $result = $cosClient->deleteBucketTagging(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
            );
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

    public function mBucketTagging() {
        $this->init();

        // 设置存储桶标签
        $this->putBucketTagging();

        // 获取存储桶标签
        $this->getBucketTagging();

        // 删除存储桶标签
        $this->deleteBucketTagging();

	    //.cssg-methods-pragma
    }
}
?>