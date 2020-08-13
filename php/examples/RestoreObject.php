<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class RestoreObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 恢复归档对象
    protected function restoreObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[restore-object]
        try {
            $result = $cosClient->restoreObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'Days' => 10,
                'CASJobParameters' => array(
                    'Tier' =>'Expedited'
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

    public function mRestoreObject() {
        $this->init();

        // 恢复归档对象
        $this->restoreObject();

	    //.cssg-methods-pragma
    }
}
?>