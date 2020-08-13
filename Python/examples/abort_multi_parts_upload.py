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

# 初始化分片上传
def init_multi_upload():
    #.cssg-snippet-body-start:[init-multi-upload]
    response = client.create_multipart_upload(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        StorageClass='STANDARD'
    )
    
    #.cssg-snippet-body-end

# 终止分片上传任务
def abort_multi_upload():
    #.cssg-snippet-body-start:[abort-multi-upload]
    response = client.abort_multipart_upload(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        UploadId='exampleUploadId'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 初始化分片上传
init_multi_upload()

# 终止分片上传任务
abort_multi_upload()

#.cssg-methods-pragma