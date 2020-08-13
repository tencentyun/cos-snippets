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

# 列出所有未完成的分片上传任务
def list_multi_upload():
    #.cssg-snippet-body-start:[list-multi-upload]
    response = client.list_multipart_uploads(
        Bucket='examplebucket-1250000000',
        Prefix='dir'
    )
    
    #.cssg-snippet-body-end

# 上传一个分片
def upload_part():
    #.cssg-snippet-body-start:[upload-part]
    # 注意，上传分块的块数最多10000块
    response = client.upload_part(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        Body=b'b'*1024*1024,
        PartNumber=1,
        UploadId='exampleUploadId'
    )
    
    #.cssg-snippet-body-end

# 列出已上传的分片
def list_parts():
    #.cssg-snippet-body-start:[list-parts]
    response = client.list_parts(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        UploadId='exampleUploadId'
    )
    
    #.cssg-snippet-body-end

# 完成分片上传任务
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

# 列出所有未完成的分片上传任务
list_multi_upload()

# 上传一个分片
upload_part()

# 列出已上传的分片
list_parts()

# 完成分片上传任务
complete_multi_upload()

#.cssg-methods-pragma