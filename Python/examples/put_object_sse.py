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

# 使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
def put_object_sse():
    #.cssg-snippet-body-start:[put-object-sse]
    response = client.put_object(
        Bucket='examplebucket-1250000000',
        Body=b'bytes'|file,
        Key='exampleobject',
        ServerSideEncryption='AES256'
    )
    
    #.cssg-snippet-body-end

# 使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
def put_object_sse_c():
    #.cssg-snippet-body-start:[put-object-sse-c]
    response = client.put_object(
        Bucket='examplebucket-1250000000',
        Body=b'bytes'|file,
        Key='exampleobject',
        SSECustomerAlgorithm='AES256',
        SSECustomerKey='string', // 客户端密钥的 base64 编码字符串
        SSECustomerKeyMD5='string' // 客户端密钥的 md5 字符串
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 使用 COS 托管加密密钥的服务端加密（SSE-COS）保护数据
put_object_sse()

# 使用客户提供的加密密钥的服务端加密 （SSE-C）保护数据
put_object_sse_c()

#.cssg-methods-pragma