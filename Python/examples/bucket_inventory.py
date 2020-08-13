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

# 设置存储桶清单任务
def put_bucket_inventory():
    #.cssg-snippet-body-start:[put-bucket-inventory]
    response = client.put_bucket_inventory(
        Bucket='examplebucket-1250000000',
        Id='string',
        InventoryConfiguration={
            'Destination': {
                'COSBucketDestination': {
                    'AccountId': '100000000001',
                    'Bucket': 'qcs::cos:ap-guangzhou::examplebucket-1250000000',
                    'Format': 'CSV',
                    'Prefix': 'string',
                    'Encryption': {
                        'SSECOS': {}
                    }
                }
            },
            'IsEnabled': 'true'|'false',
            'Filter': {
                'Prefix': 'string'
            },
            'IncludedObjectVersions':'All'|'Current',
            'OptionalFields': {
                'Field': [
                    'Size',
                    'LastModifiedDate',
                    'ETag',
                    'StorageClass',
                    'IsMultipartUploaded',
                    'ReplicationStatus'
                ]
            },
            'Schedule': {
                'Frequency': 'Daily'|'Weekly'
            }
        }
    )
    
    #.cssg-snippet-body-end

# 获取存储桶清单任务
def get_bucket_inventory():
    #.cssg-snippet-body-start:[get-bucket-inventory]
    response = client.get_bucket_inventory(
        Bucket='examplebucket-1250000000',
        Id='string'
    )
    
    #.cssg-snippet-body-end

# 删除存储桶清单任务
def delete_bucket_inventory():
    #.cssg-snippet-body-start:[delete-bucket-inventory]
    response = client.delete_bucket_inventory(
        Bucket='examplebucket-1250000000',
        Id='string'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶清单任务
put_bucket_inventory()

# 获取存储桶清单任务
get_bucket_inventory()

# 删除存储桶清单任务
delete_bucket_inventory()

#.cssg-methods-pragma