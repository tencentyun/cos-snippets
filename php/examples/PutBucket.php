<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class PutBucket
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 创建存储桶
    protected function putBucket() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket]
        try {
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $result = $cosClient->createBucket(array('Bucket' => $bucket));
            //请求成功
            print_r($result);
        } catch (\Exception $e) {
            //请求失败
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

    public function mPutBucket() {
        $this->init();

        // 创建存储桶
        $this->putBucket();

	    //.cssg-methods-pragma
    }
}
?>