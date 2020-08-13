# -*- coding=utf-8

from qcloud_cos import CosConfig
from qcloud_cos import CosS3Client
from qcloud_cos import CosServiceError
from qcloud_cos import CosClientError

secret_id = 'COS_SECRETID'     # 替换为用户的secret_id
secret_key = 'COS_SECRETKEY'     # 替换为用户的secret_key
region = 'COS_REGION'    # 替换为用户的region
token = None               # 使用临时密钥需要传入Token，默认为空,可不填
config = CosConfig(Region=region, SecretId=secret_id, SecretKey=secret_key, Token=token)  # 获取配置对象
client = CosS3Client(config)

# 获取预签名下载链接
def get_presign_download_url():
    #.cssg-snippet-body-start:[get-presign-download-url]
    response = client.get_presigned_url(
        Method='GET',
        Bucket='examplebucket-1250000000',
        Key='exampleobject'
    )
    
    #.cssg-snippet-body-end

# 获取预签名上传链接
def get_presign_upload_url():
    #.cssg-snippet-body-start:[get-presign-upload-url]
    response = client.get_presigned_url(
        Method='PUT',
        Bucket='examplebucket-1250000000',
        Key='exampleobject'
    )
    
    #.cssg-snippet-body-end

# 获取预签名下载链接
def get_presign_download_url_alias():
    #.cssg-snippet-body-start:[get-presign-download-url-alias]
    response = client.get_presigned_download_url(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        Expired=300,
        Headers={
            'Content-Length': 'string',
            'Content-MD5': 'string'
        },
        Params={
            'param1': 'string',
            'param2': 'string'
        }
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 获取预签名下载链接
get_presign_download_url()

# 获取预签名上传链接
get_presign_upload_url()

# 获取预签名下载链接
get_presign_download_url_alias()

#.cssg-methods-pragma