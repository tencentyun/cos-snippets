<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class MultiPartsUploadObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 初始化分片上传
    protected function initMultiUpload() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[init-multi-upload]
        try {
            $result = $cosClient->createMultipartUpload(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 列出所有未完成的分片上传任务
    protected function listMultiUpload() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[list-multi-upload]
        try {
            $result = $cosClient->listMultipartUploads(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Delimiter' => '/',
                'EncodingType' => 'url',
                'KeyMarker' => 'prfixKeyMarker',
                'UploadIdMarker' => 'string',
                'Prefix' => 'prfix',
                'MaxUploads' => 1000,
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 上传一个分片
    protected function uploadPart() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[upload-part]
        try {
            $result = $cosClient->uploadPart(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject', 
                'Body' => 'string',
                'UploadId' => 'exampleUploadId', //UploadId 为对象分块上传的 ID，在分块上传初始化的返回参数里获得 
                'PartNumber' => 1, //PartNumber 为分块的序列号，COS 会根据携带序列号合并分块
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 列出已上传的分片
    protected function listParts() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[list-parts]
        try {
            $result = $cosClient->listParts(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'UploadId' => 'exampleUploadId',
                'PartNumberMarker' => 1,
                'MaxParts' => 1000,
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 完成分片上传任务
    protected function completeMultiUpload() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[complete-multi-upload]
        try {
            $result = $cosClient->completeMultipartUpload(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject', 
                'UploadId' => 'exampleUploadId',
                'Parts' => array(
                    array(
                        'ETag' => 'exampleETag',
                        'PartNumber' => 1,
                    )), 
                    // ... repeated
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

    public function mMultiPartsUploadObject() {
        $this->init();

        // 初始化分片上传
        $this->initMultiUpload();

        // 列出所有未完成的分片上传任务
        $this->listMultiUpload();

        // 上传一个分片
        $this->uploadPart();

        // 列出已上传的分片
        $this->listParts();

        // 完成分片上传任务
        $this->completeMultiUpload();

	    //.cssg-methods-pragma
    }
}
?>