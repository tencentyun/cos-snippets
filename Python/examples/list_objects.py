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

# 获取对象列表
def get_bucket():
    #.cssg-snippet-body-start:[get-bucket]
    response = client.list_objects(
        Bucket='examplebucket-1250000000',
        Prefix='folder1'
    )
    
    #.cssg-snippet-body-end

# 获取对象列表
def get_bucket_comp():
    #.cssg-snippet-body-start:[get-bucket-comp]
    response = client.list_objects(
        Bucket='examplebucket-1250000000',
        Prefix='string',
        Delimiter='/',
        Marker='string',
        MaxKeys=100,
        EncodingType='url'
    )
    
    #.cssg-snippet-body-end

# 获取对象列表
def get_bucket_recursive():
    #.cssg-snippet-body-start:[get-bucket-recursive]
    marker = ""
    while True:
        response = client.list_objects(
            Bucket='examplebucket-1250000000',
            Prefix='folder1',
            Marker=marker
        )
        print(response['Contents'])
        if response['IsTruncated'] == 'false':
            break 
        marker = response['NextMarker']
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 获取对象列表
get_bucket()

# 获取对象列表
get_bucket_comp()

# 获取对象列表
get_bucket_recursive()

#.cssg-methods-pragma