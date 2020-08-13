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

# 设置存储桶多版本
def put_bucket_versioning():
    #.cssg-snippet-body-start:[put-bucket-versioning]
    response = client.put_bucket_versioning(
        Bucket='examplebucket-1250000000',
        Status='Enabled'
    )
    
    #.cssg-snippet-body-end

# 获取存储桶多版本状态
def get_bucket_versioning():
    #.cssg-snippet-body-start:[get-bucket-versioning]
    response = client.get_bucket_versioning(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶多版本
put_bucket_versioning()

# 获取存储桶多版本状态
get_bucket_versioning()

#.cssg-methods-pragma