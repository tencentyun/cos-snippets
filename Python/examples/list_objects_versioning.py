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

# 获取对象多版本列表第一页数据
def list_objects_versioning():
    #.cssg-snippet-body-start:[list-objects-versioning]
    response = client.list_objects_versions(
        Bucket='examplebucket-1250000000',
        Prefix='string'
    )
    
    #.cssg-snippet-body-end

# 获取对象多版本列表下一页数据
def list_objects_versioning_next_page():
    #.cssg-snippet-body-start:[list-objects-versioning-next-page]
    response = client.list_objects_versions(
        Bucket='examplebucket-1250000000',
        Prefix='string',
        Delimiter='/',
        KeyMarker='string',
        VersionIdMarker='string',
        MaxKeys=100,
        EncodingType='url'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 获取对象多版本列表第一页数据
list_objects_versioning()

# 获取对象多版本列表下一页数据
list_objects_versioning_next_page()

#.cssg-methods-pragma