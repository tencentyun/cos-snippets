<?php

use Qcloud\Cos\Client;
use Qcloud\Cos\Exception\ServiceResponseException;

class {{name}}
{
    private $cosClient;

    private $uploadId;
    private $eTag;
    private $versionId;

    {{#methods}}
    // {{description}}
    protected function {{name}}() {
        $cosClient = $this->cosClient;
        {{{startTag}}}
        {{{snippet}}}
        {{{endTag}}}
    }

    {{/methods}}
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

    public function m{{name}}() {
        $this->init();

        {{#methods}}
        // {{description}}
        $this->{{name}}();

        {{/methods}}
	    //.cssg-methods-pragma
    }
}
?>