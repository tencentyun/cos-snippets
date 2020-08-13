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

# 设置存储桶跨域规则
def put_bucket_cors():
    #.cssg-snippet-body-start:[put-bucket-cors]
    response = client.put_bucket_cors(
        Bucket='examplebucket-1250000000',
        CORSConfiguration={
            'CORSRule': [
                {
                    'ID': 'string',
                    'MaxAgeSeconds': 100,
                    'AllowedOrigin': [
                        'string',
                    ],
                    'AllowedMethod': [
                        'string',
                    ],
                    'AllowedHeader': [
                        'string',
                    ],
                    'ExposeHeader': [
                        'string',
                    ]
                }
            ]
        },
    )
    
    #.cssg-snippet-body-end

# 获取存储桶跨域规则
def get_bucket_cors():
    #.cssg-snippet-body-start:[get-bucket-cors]
    response = client.get_bucket_cors(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

# 删除存储桶跨域规则
def delete_bucket_cors():
    #.cssg-snippet-body-start:[delete-bucket-cors]
    response = client.delete_bucket_cors(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶跨域规则
put_bucket_cors()

# 获取存储桶跨域规则
get_bucket_cors()

# 删除存储桶跨域规则
delete_bucket_cors()

#.cssg-methods-pragma