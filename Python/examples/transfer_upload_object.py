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

# 高级接口上传对象
def transfer_upload_file():
    #.cssg-snippet-body-start:[transfer-upload-file]
    response = client.upload_file(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        LocalFilePath='local.txt',
        EnableMD5=False
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 高级接口上传对象
transfer_upload_file()

#.cssg-methods-pragma