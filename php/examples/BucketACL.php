<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class BucketACL
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    // 设置存储桶 ACL
    protected function putBucketAcl() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[put-bucket-acl]
        try {
            $result = $cosClient->putBucketAcl(array(
                'Bucket' => 'examplebucket-1250000000', //格式：BucketName-APPID
                'ACL' => 'private',
                'Grants' => array(
                    array(
                        'Grantee' => array(
                            'DisplayName' => 'qcs::cam::uin/100000000001:uin/100000000001',
                            'ID' => 'qcs::cam::uin/100000000001:uin/100000000001',
                            'Type' => 'CanonicalUser',
                        ),  
                        'Permission' => 'FULL_CONTROL',
                    ),  
                    // ... repeated
                ),  
                'Owner' => array(
                    'DisplayName' => 'qcs::cam::uin/100000000001:uin/100000000001',
                    'ID' => 'qcs::cam::uin/100000000001:uin/100000000001',
                )));
            // 请求成功
            print_r($result);
        } catch (\Exception $e) {
            // 请求失败
            echo "$e\n";
        }
        
        //.cssg-snippet-body-end
    }

    // 获取存储桶 ACL
    protected function getBucketAcl() {
        $cosClient = $this->cosClient;
        //.cssg-snippet-body-start:[get-bucket-acl]
        try {
            $result = $cosClient->getBucketAcl(array(
                'Bucket' => 'examplebucket-1250000000' //格式：BucketName-APPID
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

    public function mBucketACL() {
        $this->init();

        // 设置存储桶 ACL
        $this->putBucketAcl();

        // 获取存储桶 ACL
        $this->getBucketAcl();

	    //.cssg-methods-pragma
    }
}
?>