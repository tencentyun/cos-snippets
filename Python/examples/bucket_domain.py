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

# 设置存储桶自定义域名
def put_bucket_domain():
    #.cssg-snippet-body-start:[put-bucket-domain]
    put_bucket_domain(Bucket, DomainConfiguration={}, **kwargs)
    
    #.cssg-snippet-body-end

# 获取存储桶自定义域名
def get_bucket_domain():
    #.cssg-snippet-body-start:[get-bucket-domain]
    response = client.get_bucket_domain(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

# 删除存储桶自定义域名
def delete_bucket_domain():
    #.cssg-snippet-body-start:[delete-bucket-domain]
    response = client.delete_bucket_domain(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶自定义域名
put_bucket_domain()

# 获取存储桶自定义域名
get_bucket_domain()

# 删除存储桶自定义域名
delete_bucket_domain()

#.cssg-methods-pragma