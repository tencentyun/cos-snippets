<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class GetObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 下载对象
    protected function getObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-object]
        try {
            $result = $cosClient->getObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'SaveAs' => 'path/to/localFile',
            )); 
            // 请求成功
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 下载对象
    protected function getObjectRange() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-object-range]
        try {
            $result = $cosClient->getObject(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'Key' => 'exampleobject',
                'Range' => 'bytes=0-10'
            )); 
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo($e);
        }
        
        //.cssg-snippet-body-end
    }

    // 下载对象
    protected function getObjectWithVersionId() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-object-with-versionId]
        try {
            $result = $cosClient->getObject(array(
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

    // 下载对象
    protected function getObjectComp() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-object-comp]
        # 下载文件
        ## getObject(下载文件)
        ### 下载到内存
        try {
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key = "exampleobject"; //对象在存储桶中的位置，即称对象键
            $result = $cosClient->getObject(array(
                'Bucket' => $bucket,
                'Key' => $key));
            // 请求成功
            echo($result['Body']);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        ### 下载到本地
        try {
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key = "exampleobject"; //对象在存储桶中的位置，即称对象键
            $localPath = @"path/to/localFile";//下载到本地指定路径
            $result = $cosClient->getObject(array(
                'Bucket' => $bucket,
                'Key' => $key,
                'SaveAs' => $localPath));
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        ### 指定下载范围
        /*
         * Range 字段格式为 'bytes=a-b'
         */
        try {
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key = "exampleobject"; //对象在存储桶中的位置，即称对象键
            $localPath = @"path/to/localFile";//下载到本地指定路径
            $result = $cosClient->getObject(array(
                'Bucket' => $bucket,
                'Key' => $key,
                'Range' => 'bytes=0-10',
                'SaveAs' => $localPath));
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        ## getObjectUrl(获取文件 UrL)
        try {    
            $bucket = "examplebucket-1250000000"; //存储桶，格式：BucketName-APPID
            $key = "exampleobject"; //对象在存储桶中的位置，即称对象键
            $signedUrl = $cosClient->getObjectUrl($bucket, $key, '+10 minutes');
            // 请求成功
            echo $signedUrl;
        } catch (\Exception $e) {
            // 请求失败
            print_r($e);
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

    public function mGetObject() {
        $this->init();

        // 下载对象
        $this->getObject();

        // 下载对象
        $this->getObjectRange();

        // 下载对象
        $this->getObjectWithVersionId();

        // 下载对象
        $this->getObjectComp();

	    //.cssg-methods-pragma
    }
}
?>