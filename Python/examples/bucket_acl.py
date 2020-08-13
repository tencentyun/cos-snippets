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

# 设置存储桶 ACL
def put_bucket_acl():
    #.cssg-snippet-body-start:[put-bucket-acl]
    response = client.put_bucket_acl(
        Bucket='examplebucket-1250000000',
        ACL='public-read'
    )
    
    #.cssg-snippet-body-end

# 获取存储桶 ACL
def get_bucket_acl():
    #.cssg-snippet-body-start:[get-bucket-acl]
    response = client.get_bucket_acl(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶 ACL
put_bucket_acl()

# 获取存储桶 ACL
get_bucket_acl()

#.cssg-methods-pragma