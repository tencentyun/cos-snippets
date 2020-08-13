<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class GetService
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 获取存储桶列表
    protected function getService() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-service]
        try {
            //请求成功
            $result = $cosClient->listBuckets();
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

    public function mGetService() {
        $this->init();

        // 获取存储桶列表
        $this->getService();

	    //.cssg-methods-pragma
    }
}
?>