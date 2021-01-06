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

# 检索对象内容
def select_object_content():
    #.cssg-snippet-body-start:[select-object-content]
    response = client.select_object_content(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        Expression='Select * from COSObject',
        ExpressionType='SQL',
        InputSerialization={
            'CompressionType': 'NONE',
            'JSON': {
                'Type': 'LINES'
            }
        },
        OutputSerialization={
            'CSV': {
                'RecordDelimiter': '\n'
            }
        }
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 检索对象内容
select_object_content()

#.cssg-methods-pragma