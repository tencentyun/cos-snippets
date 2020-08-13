<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class ObjectPresignUrl
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 获取预签名下载链接
    protected function getPresignDownloadUrl() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-presign-download-url]
        $secretId = "COS_SECRETID"; //替换为您的永久密钥 SecretId
        $secretKey = "COS_SECRETKEY"; //替换为您的永久密钥 SecretKey
        $region = "ap-beijing"; //设置一个默认的存储桶地域
        $cosClient = new Qcloud\Cos\Client(
            array(
                'region' => $region,
                'schema' => 'https', //协议头部，默认为 http
                'credentials'=> array(
                    'secretId'  => $secretId,
                    'secretKey' => $secretKey)));
        ### 简单下载预签名
        try {
            $signedUrl = $cosClient->getPresignetUrl('getObject', array(
                'Bucket' => "examplebucket-1250000000", //存储桶，格式：BucketName-APPID
                'Key' => "exampleobject", //对象在存储桶中的位置，即对象键
                ), '+10 minutes'); //签名的有效时间
            // 请求成功
            echo ($signedUrl);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        ### 使用封装的 getObjectUrl 获取下载签名
        try {    
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key = "exampleobject"; //对象在存储桶中的位置，即对象键
            $signedUrl = $cosClient->getObjectUrl($bucket, $key, '+10 minutes'); //签名的有效时间
            // 请求成功
            echo $signedUrl;
        } catch (\Exception $e) {
            // 请求失败
            print_r($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 获取预签名上传链接
    protected function getPresignUploadUrl() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-presign-upload-url]
        $secretId = "COS_SECRETID"; //替换为您的永久密钥 SecretId
        $secretKey = "COS_SECRETKEY"; //替换为您的永久密钥 SecretKey
        $region = "ap-beijing"; //设置一个默认的存储桶地域
        $cosClient = new Qcloud\Cos\Client(
            array(
                'region' => $region,
                'schema' => 'https', //协议头部，默认为 http
                'credentials'=> array(
                    'secretId'  => $secretId ,
                    'secretKey' => $secretKey)));
        ### 简单上传预签名
        try {
            $signedUrl = $cosClient->getPresignetUrl('putObject', array(
                'Bucket' => "examplebucket-1250000000", //存储桶，格式：BucketName-APPID
                'Key' => "exampleobject", //对象在存储桶中的位置，即对象键
                'Body' => 'string' //可为空或任意字符串
            ), '+10 minutes'); //签名的有效时间
            // 请求成功
            echo ($signedUrl);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        ### 分块上传预签名
        try {
            $signedUrl = $cosClient->getPresignetUrl('uploadPart', array(
                    'Bucket' => "examplebucket-1250000000", //存储桶，格式：BucketName-APPID
                    'Key' => "exampleobject", //对象在存储桶中的位置，即对象键
                    'UploadId' => 'string',
                    'PartNumber' => '1',
                    'Body' => 'string'), '+10 minutes'); //签名的有效时间
            // 请求成功
            echo ($signedUrl);
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

    public function mObjectPresignUrl() {
        $this->init();

        // 获取预签名下载链接
        $this->getPresignDownloadUrl();

        // 获取预签名上传链接
        $this->getPresignUploadUrl();

	    //.cssg-methods-pragma
    }
}
?>