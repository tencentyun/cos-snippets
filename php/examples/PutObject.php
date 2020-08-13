<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class PutObject
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 简单上传对象
    protected function putObject() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-object]
        try { 
            $result = $cosClient->putObject(array( 
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID 
                'Key' => 'exampleobject', 
                'Body' => fopen('path/to/localFile', 'rb'), 
            )); 
            // 请求成功 
            print_r($result);
        } catch (\Exception $e) { 
            // 请求失败 
            echo($e); 
        }
        
        //.cssg-snippet-body-end
    }

    // 简单上传对象
    protected function putObjectArchive() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-object-archive]
        try { 
            $result = $cosClient->putObject(array( 
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID 
                'Key' => 'exampleobject', 
                'Body' => fopen('path/to/localFile', 'rb'), 
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

    // 简单上传对象
    protected function putObjectWithContentType() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-object-with-content-type]
        try { 
            $result = $cosClient->putObject(array( 
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID 
                'Key' => 'exampleobject', 
                'Body' => fopen('path/to/localFile', 'rb'), 
                'ContentType' => 'text/xml'
            )); 
            // 请求成功 
            print_r($result); 
        } catch (\Exception $e) { 
            // 请求失败 
            echo($e); 
        }
        
        //.cssg-snippet-body-end
    }

    // 简单上传对象
    protected function putObjectComp() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-object-comp]
        # 上传文件
        ## putObject(上传接口，最大支持上传5G文件)
        ### 上传内存中的字符串
        try {
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $key = "exampleobject";
            $result = $cosClient->putObject(array(
                'Bucket' => $bucket,
                'Key' => $key,
                'Body' => 'Hello World!'));
            print_r($result);
        } catch (\Exception $e) {
            echo "$e\n";
        }
        
        ### 上传文件流
        try {
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $key = "exampleobject";
            $srcPath = "path/to/localFile";//本地文件绝对路径
            $file = fopen($srcPath, "rb");
            if ($file) {
                $result = $cosClient->putObject(array(
                    'Bucket' => $bucket,
                    'Key' => $key,
                    'Body' => $file));
                print_r($result);
            }
        } catch (\Exception $e) {
            echo "$e\n";
        }
        
        ## Upload(高级上传接口，默认使用分块上传最大支持50T)
        ### 上传内存中的字符串
        try {    
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $key = "exampleobject";
            $result = $cosClient->Upload(
                $bucket = $bucket,
                $key = $key,
                $body = 'Hello World!');
            print_r($result);
        } catch (\Exception $e) {
            echo "$e\n";
        }
        
        ### 上传文件流
        try {    
            $bucket = "examplebucket-1250000000"; //存储桶名称 格式：BucketName-APPID
            $key = "exampleobject";
            $srcPath = "path/to/localFile";//本地文件绝对路径
            $file = fopen($srcPath, 'rb');
            if ($file) {
                $result = $cosClient->Upload(
                    $bucket = $bucket,
                    $key = $key,
                    $body = $file);
            }
            print_r($result);
        } catch (\Exception $e) {
            echo "$e\n";
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

    public function mPutObject() {
        $this->init();

        // 简单上传对象
        $this->putObject();

        // 简单上传对象
        $this->putObjectArchive();

        // 简单上传对象
        $this->putObjectWithContentType();

        // 简单上传对象
        $this->putObjectComp();

	    //.cssg-methods-pragma
    }
}
?>