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

# 设置存储桶生命周期
def put_bucket_lifecycle():
    #.cssg-snippet-body-start:[put-bucket-lifecycle]
    response = client.put_bucket_lifecycle(
        Bucket='examplebucket-1250000000',
        LifecycleConfiguration={
            'Rule': [
                {
                    'ID': 'string',
                    'Filter': {
                        'Prefix': '',
                    },
                    'Status': 'Enabled',
                    'Expiration': {
                        'Days': 200
                    },
                    'Transition': [
                        {
                            'Days': 100,
                            'StorageClass': 'Standard_IA'
                        },
                    ],
                    'AbortIncompleteMultipartUpload': {
                        'DaysAfterInitiation': 7
                    }
                }
            ]   
        }
    )
    
    #.cssg-snippet-body-end

# 获取存储桶生命周期
def get_bucket_lifecycle():
    #.cssg-snippet-body-start:[get-bucket-lifecycle]
    response = client.get_bucket_lifecycle(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

# 删除存储桶生命周期
def delete_bucket_lifecycle():
    #.cssg-snippet-body-start:[delete-bucket-lifecycle]
    response = client.delete_bucket_lifecycle(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶生命周期
put_bucket_lifecycle()

# 获取存储桶生命周期
get_bucket_lifecycle()

# 删除存储桶生命周期
delete_bucket_lifecycle()

#.cssg-methods-pragma