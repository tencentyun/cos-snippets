<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class TransferUploadObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 高级接口上传对象
    protected function transferUploadFile() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[transfer-upload-file]
        try {
            $result = $cosClient->Upload(
                $bucket = 'examplebucket-1250000000', //格式：BucketName-APPID
                $key = 'exampleobject',
                $body = fopen('path/to/localFile', 'rb')
            );
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 高级接口上传对象
    protected function transferUploadFileArchive() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[transfer-upload-file-archive]
        try {
            $result = $cosClient->Upload(
                $bucket = 'examplebucket-1250000000', //格式：BucketName-APPID
                $key = 'exampleobject',
                $body = fopen('path/to/localFile', 'rb'),
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

    // 高级接口上传对象
    protected function transferUploadFileWithMeta() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[transfer-upload-file-with-meta]
        try {
            $result = $cosClient->Upload(
                $bucket = 'examplebucket-1250000000', //格式：BucketName-APPID
                $key = 'exampleobject',
                $body = fopen('path/to/localFile', 'rb'),
                $options = array(
                    'Metadata' => array(
                        'string' => 'string',
                    ),
                    'PartSize' => 10 * 1024 * 1024
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

    public function mTransferUploadObject() {
        $this->init();

        // 高级接口上传对象
        $this->transferUploadFile();

        // 高级接口上传对象
        $this->transferUploadFileArchive();

        // 高级接口上传对象
        $this->transferUploadFileWithMeta();

	    //.cssg-methods-pragma
    }
}
?>