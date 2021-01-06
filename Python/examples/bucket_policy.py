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

# 设置存储桶 Policy
def put_bucket_policy():
    #.cssg-snippet-body-start:[put-bucket-policy]
    response = client.put_bucket_policy(
        Bucket='examplebucket-1250000000',
        Policy={
            "Statement": [
                {
                    "Principal": {
                        "qcs": [
                        "qcs::cam::uin/100000000001:uin/100000000011"
                        ]
                    },
                    "Effect": "allow",
                    "Action": [
                        "name/cos:GetBucket"
                    ],
                    "Resource": [
                        "qcs::cos:ap-guangzhou:uid/1250000000:examplebucket-1250000000/*"
                    ]
                    "condition": {
                        "ip_equal": {
                        "qcs:ip": "10.121.2.10/24"
                        }
                    }
                }
            ],
            "version": "2.0"
        }
    )
    
    #.cssg-snippet-body-end

# 获取存储桶 Policy
def get_bucket_policy():
    #.cssg-snippet-body-start:[get-bucket-policy]
    response = client.delete_bucket_policy(
        Bucket='examplebucket-1250000000',
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 设置存储桶 Policy
put_bucket_policy()

# 获取存储桶 Policy
get_bucket_policy()

#.cssg-methods-pragma