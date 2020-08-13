<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class TransferCopyObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 高级接口拷贝对象
    protected function transferCopyObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[transfer-copy-object]
        try {
            $result = $cosClient->Copy(
                $bucket = 'examplebucket-1250000000', //格式：BucketName-APPID
                $key = 'exampleobject',
                $copySorce = array(
                    'Region' => 'COS_REGION', 
                    'Bucket' => 'sourcebucket-1250000000', 
                    'Key' => 'sourceObject', 
                )
            );
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 高级接口拷贝对象
    protected function transferCopyObjectUpdateStorageClass() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[transfer-copy-object-update-storage-class]
        try {
            $result = $cosClient->Copy(
                $bucket = 'examplebucket-1250000000', //格式：BucketName-APPID
                $key = 'exampleobject',
                $copySorce = array(
                    'Region' => 'COS_REGION', 
                    'Bucket' => 'examplebucket-1250000000', 
                    'Key' => 'exampleobject', 
                ),
                $options = array(
                    'StorageClass' => 'Archive'
                )
            );
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 高级接口拷贝对象
    protected function transferCopyObjectUpdateMetadata() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[transfer-copy-object-update-metadata]
        try {
            $result = $cosClient->Copy(
                $bucket = 'examplebucket-1250000000', //格式：BucketName-APPID
                $key = 'exampleobject',
                $copySorce = array(
                    'Region' => 'COS_REGION', 
                    'Bucket' => 'sourcebucket-1250000000', 
                    'Key' => 'sourceObject', 
                ),
                $options = array(
                    'MetadataDirective' => 'Replaced',
                    'Metadata' => array(
                        'string' => 'string',
                    ),
                )
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

    public function mTransferCopyObject() {
        $this->init();

        // 高级接口拷贝对象
        $this->transferCopyObject();

        // 高级接口拷贝对象
        $this->transferCopyObjectUpdateStorageClass();

        // 高级接口拷贝对象
        $this->transferCopyObjectUpdateMetadata();

	    //.cssg-methods-pragma
    }
}
?>