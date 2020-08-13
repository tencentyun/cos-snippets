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

# 设置存储桶静态网站
def put_bucket_website():
    #.cssg-snippet-body-start:[put-bucket-website]
    response = client.put_bucket_website(
        Bucket='bucket',
        WebsiteConfiguration={
            'IndexDocument': {
                'Suffix': 'string'
            },
            'ErrorDocument': {
                'Key': 'string'
            },
            'RedirectAllRequestsTo': {
                'Protocol': 'http'|'https'
            },
            'RoutingRules': [
                {
                    'Condition': {
                        'HttpErrorCodeReturnedEquals': 'string',
                        'KeyPrefixEquals': 'string'
                    },
                    'Redirect': {
                        'HttpRedirectCode': 'string',
                        'Protocol': 'http'|'https',
                        'ReplaceKeyPrefixWith': 'string',
                        'ReplaceKeyWith': 'string'
                    }
                }
            ]
        }
    )
    
    #.cssg-snippet-body-end

# 获取存储桶静态网站
def get_bucket_website():
    #.cssg-snippet-body-start:[get-bucket-website]
    response = client.get_bucket_website(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

# 删除存储桶静态网站
def delete_bucket_website():
    #.cssg-snippet-body-start:[delete-bucket-website]
    response = client.delete_bucket_website(
        Bucket='examplebucket-1250000000'
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶静态网站
put_bucket_website()

# 获取存储桶静态网站
get_bucket_website()

# 删除存储桶静态网站
delete_bucket_website()

#.cssg-methods-pragma