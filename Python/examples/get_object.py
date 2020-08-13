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

# 下载对象
def get_object():
    #.cssg-snippet-body-start:[get-object]
    response = client.get_object(
        Bucket='examplebucket-1250000000',
        Key='exampleobject',
        Range='string',
        IfMatch='"9a4802d5c99dafe1c04da0a8e7e166bf"',
        IfModifiedSince='Wed, 28 Oct 2014 20:30:00 GMT',
        IfNoneMatch='"9a4802d5c99dafe1c04da0a8e7e166bf"',
        IfUnmodifiedSince='Wed, 28 Oct 2014 20:30:00 GMT',
        ResponseCacheControl='string',
        ResponseContentDisposition='string',
        ResponseContentEncoding='string',
        ResponseContentLanguage='string',
        ResponseContentType='string',
        ResponseExpires='string',
        VersionId='string'
    )
    
    #.cssg-snippet-body-end

# 下载对象
def get_object_comp():
    #.cssg-snippet-body-start:[get-object-comp]
    ####  获取文件到本地
    response = client.get_object(
        Bucket='examplebucket-1250000000',
        Key='picture.jpg',
    )
    response['Body'].get_stream_to_file('output.txt')
    
    #### 获取文件流
    response = client.get_object(
        Bucket='examplebucket-1250000000',
        Key='picture.jpg',
    )
    fp = response['Body'].get_raw_stream()
    print(fp.read(2))
    
    #### 设置 Response HTTP 头部
    response = client.get_object(
        Bucket='examplebucket-1250000000',
        Key='picture.jpg',
        ResponseContentType='text/html; charset=utf-8'
    )
    print(response['Content-Type'])
    fp = response['Body'].get_raw_stream()
    print(fp.read(2))
    
    #### 指定下载范围
    response = client.get_object(
        Bucket='examplebucket-1250000000',
        Key='picture.jpg',
        Range='bytes=0-10'
    )
    fp = response['Body'].get_raw_stream()
    print(fp.read())
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 下载对象
get_object()

# 下载对象
get_object_comp()

#.cssg-methods-pragma