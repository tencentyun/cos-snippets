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

# 开启存储桶日志服务
def put_bucket_logging():
    #.cssg-snippet-body-start:[put-bucket-logging]
    response = client.put_bucket_logging(
        Bucket='examplebucket-1250000000',
        BucketLoggingStatus={
            'LoggingEnabled': {
                'TargetBucket': 'logging-bucket-1250000000',
                'TargetPrefix': 'string'
            }
        }
    )
    
    #.cssg-snippet-body-end

# 获取存储桶日志服务
def get_bucket_logging():
    #.cssg-snippet-body-start:[get-bucket-logging]
    response = client.get_bucket_logging(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 开启存储桶日志服务
put_bucket_logging()

# 获取存储桶日志服务
get_bucket_logging()

#.cssg-methods-pragma