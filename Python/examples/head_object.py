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

# 获取对象信息
def head_object():
    #.cssg-snippet-body-start:[head-object]
    response = client.head_object(
        Bucket='examplebucket-1250000000',
        Key='exampleobject'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 获取对象信息
head_object()

#.cssg-methods-pragma