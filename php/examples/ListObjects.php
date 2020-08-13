<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class ListObjects
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 获取对象列表
    protected function getBucket() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket]
        try {
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $result = $cosClient->listObjects(array(
                'Bucket' => $bucket
            ));
            // 请求成功
            if (isset($result['Contents'])) {
                foreach ($result['Contents'] as $rt) {
                    print_r($rt);
                }
            }
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 获取对象列表
    protected function getBucketComp() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-comp]
        try {
            $result = $cosClient->listObjects(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Delimiter' => '',
                'EncodingType' => 'url',
                'Marker' => 'doc/picture.jpg',
                'Prefix' => 'doc',
                'MaxKeys' => 1000,
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 获取对象列表
    protected function getBucketRecursive() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-recursive]
        try {
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $prefix = ''; //列出对象的前缀
            $marker = ''; //上次列出对象的断点
            while (true) {
                $result = $cosClient->listObjects(array(
                    'Bucket' => $bucket,
                    'Marker' => $marker,
                    'MaxKeys' => 1000 //设置单次查询打印的最大数量，最大为1000
                ));
                if (isset($result['Contents'])) {
                    foreach ($result['Contents'] as $rt) {
                        // 打印key
                        echo($rt['Key'] . "\n");
                    }
                }
                $marker = $result['NextMarker']; //设置新的断点
                if (!$result['IsTruncated']) {
                    break; //判断是否已经查询完
                }
            }
        } catch (\Exception $e) {
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

    public function mListObjects() {
        $this->init();

        // 获取对象列表
        $this->getBucket();

        // 获取对象列表
        $this->getBucketComp();

        // 获取对象列表
        $this->getBucketRecursive();

	    //.cssg-methods-pragma
    }
}
?>