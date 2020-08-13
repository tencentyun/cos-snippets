<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class DeleteObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 删除对象
    protected function deleteObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-object]
        try {
            $result = $cosClient->deleteObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'VersionId' => 'exampleVersionId'
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 删除多个对象
    protected function deleteMultiObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-multi-object]
        try {
            $result = $cosClient->deleteObjects(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Objects' => array(
                    array(
                        'Key' => 'exampleobject',
                        'VersionId' => 'string'
                    ),  
                    // ... repeated
                ),  
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 删除对象
    protected function deleteObjectComp() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[delete-object-comp]
        # 删除 object
        ## deleteObject
        try {
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key = "exampleobject"; //对象在存储桶中的位置，即称对象键
            $result = $cosClient->deleteObject(array(
                'Bucket' => $bucket,
                'Key' => $key,
                'VersionId' => 'string'
            ));
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        # 删除多个 object
        ## deleteObjects
        try {
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key1 = "exampleobject1"; //对象在存储桶中的位置，即称对象键
            $key2 = "exampleobject2"; //对象在存储桶中的位置，即称对象键
            $result = $cosClient->deleteObjects(array(
                'Bucket' => $bucket,
                'Objects' => array(
                    array(
                        'Key' => $key1,
                    ),
                    array(
                        'Key' => $key2,
                    ),
                    //...
                ),
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

    public function mDeleteObject() {
        $this->init();

        // 删除对象
        $this->deleteObject();

        // 删除多个对象
        $this->deleteMultiObject();

        // 删除对象
        $this->deleteObjectComp();

	    //.cssg-methods-pragma
    }
}
?>