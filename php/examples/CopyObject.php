<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class CopyObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 复制对象时保留对象属性
    protected function copyObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[copy-object]
        try {
            $result = $cosClient->copyObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'CopySource' => 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject',
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 复制对象时保留对象属性
    protected function copyObjectWithVersionId() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[copy-object-with-versionId]
        try {
            $result = $cosClient->copyObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'CopySource' => 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject?versionId=MTg0NDUxNjI3NTM0ODE2Njc0MzU',
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 复制对象时保留对象属性
    protected function copyObjectUpdateStorageClass() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[copy-object-update-storage-class]
        try {
            $result = $cosClient->copyObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'CopySource' => 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject',
                'StorageClass' => 'Archive'
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 复制对象时保留对象属性
    protected function copyObjectUpdateMetadata() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[copy-object-update-metadata]
        try {
            $result = $cosClient->copyObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'CopySource' => 'sourcebucket-1250000000.cos.ap-guangzhou.myqcloud.com/sourceObject',
                'MetadataDirective' => 'Replaced',
                'Metadata' => array(
                    'key1' => 'value1',
                    'key2' => 'value2',
                )
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

    public function mCopyObject() {
        $this->init();

        // 复制对象时保留对象属性
        $this->copyObject();

        // 复制对象时保留对象属性
        $this->copyObjectWithVersionId();

        // 复制对象时保留对象属性
        $this->copyObjectUpdateStorageClass();

        // 复制对象时保留对象属性
        $this->copyObjectUpdateMetadata();

	    //.cssg-methods-pragma
    }
}
?>