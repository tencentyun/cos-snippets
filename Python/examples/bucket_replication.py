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

# 设置存储桶跨地域复制规则
def put_bucket_replication():
    #.cssg-snippet-body-start:[put-bucket-replication]
    response = client.put_bucket_replication(
        Bucket='examplebucket-1250000000',
        ReplicationConfiguration={
            'Role': 'qcs::cam::uin/100000000001:uin/100000000001',
            'Rule': [
                {
                    'ID': 'string',
                    'Status': 'Enabled',
                    'Destination': {
                        'Bucket': 'qcs::cos:ap-shanghai::destinationbucket-1250000000',
                        'StorageClass': 'STANDARD'
                    }
                }
            ]   
        }
    )
    
    #.cssg-snippet-body-end

# 获取存储桶跨地域复制规则
def get_bucket_replication():
    #.cssg-snippet-body-start:[get-bucket-replication]
    response = client.get_bucket_replication(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

# 删除存储桶跨地域复制规则
def delete_bucket_replication():
    #.cssg-snippet-body-start:[delete-bucket-replication]
    response = client.delete_bucket_replication(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶跨地域复制规则
put_bucket_replication()

# 获取存储桶跨地域复制规则
get_bucket_replication()

# 删除存储桶跨地域复制规则
delete_bucket_replication()

#.cssg-methods-pragma