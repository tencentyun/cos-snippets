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

# 恢复归档对象
def restore_object():
    #.cssg-snippet-body-start:[restore-object]
    response = client.restore_object(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        RestoreRequest={
            'Days': 100,
            'CASJobParameters': {
                'Tier': 'Standard'
            }
        }
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 恢复归档对象
restore_object()

#.cssg-methods-pragma