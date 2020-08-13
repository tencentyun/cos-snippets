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

# 初始化分片上传
def init_multi_upload():
    #.cssg-snippet-body-start:[init-multi-upload]
    response = client.create_multipart_upload(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        StorageClass='STANDARD'
    )
    
    #.cssg-snippet-body-end

# 拷贝一个分片
def upload_part_copy():
    #.cssg-snippet-body-start:[upload-part-copy]
    response = client.upload_part_copy(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        PartNumber=1,
        UploadId='exampleUploadId',
        CopySource={
            'Bucket': 'sourcebucket-1250000000', 
            'Key': 'exampleobject', 
            'Region': 'ap-guangzhou'
        }
    )
    
    #.cssg-snippet-body-end

# 完成分片拷贝任务
def complete_multi_upload():
    #.cssg-snippet-body-start:[complete-multi-upload]
    response = client.complete_multipart_upload(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        UploadId='exampleUploadId',
        MultipartUpload={
            'Part': [
                {
                    'ETag': 'string',
                    'PartNumber': 1
                },
                {
                    'ETag': 'string',
                    'PartNumber': 2
                },
            ]
        },
    )
    
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 初始化分片上传
init_multi_upload()

# 拷贝一个分片
upload_part_copy()

# 完成分片拷贝任务
complete_multi_upload()

#.cssg-methods-pragma