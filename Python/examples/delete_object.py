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

# 删除对象
def delete_object():
    #.cssg-snippet-body-start:[delete-object]
    response = client.delete_object(
        Bucket='examplebucket-1250000000',
        Key='exampleobject'
    )
    
    #.cssg-snippet-body-end

# 删除多个对象
def delete_multi_object():
    #.cssg-snippet-body-start:[delete-multi-object]
    response = client.delete_objects(
        Bucket='examplebucket-1250000000',
        Delete={
            'Object': [
                {
                    'Key': 'exampleobject1'
                },
                {
                    'Key': 'exampleobject2'
                }
            ]
        }
    )
    
    #.cssg-snippet-body-end

# 删除对象
def delete_object_comp():
    #.cssg-snippet-body-start:[delete-object-comp]
    # 删除object
    ## deleteObject
    response = client.delete_object(
        Bucket='examplebucket-1250000000',
        Key='exampleobject'
    )
    
    # 删除多个object
    ## deleteObjects
    response = client.delete_objects(
        Bucket='examplebucket-1250000000',
        Delete={
            'Object': [
                {
                    'Key': 'exampleobject1',
                },
                {
                    'Key': 'exampleobject2',
                },
            ],
            'Quiet': 'true'|'false'
        }
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 删除对象
delete_object()

# 删除多个对象
delete_multi_object()

# 删除对象
delete_object_comp()

#.cssg-methods-pragma