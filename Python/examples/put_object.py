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

# 简单上传对象
def put_object():
    #.cssg-snippet-body-start:[put-object]
    response = client.put_object(
        Bucket='examplebucket-1250000000',
        Body=b'bytes',
        Key='exampleobject',
        EnableMD5=False
    )
    
    #.cssg-snippet-body-end

# 简单上传对象
def put_object_comp():
    #.cssg-snippet-body-start:[put-object-comp]
    response = client.put_object(
        Bucket='examplebucket-1250000000',
        Body=b'bytes'|file,
        Key='exampleobject',
        EnableMD5=False|True,
        ACL='private'|'public-read',  # 请慎用此参数,否则会达到1000条 ACL 上限
        GrantFullControl='string',
        GrantRead='string',
        StorageClass='STANDARD'|'STANDARD_IA'|'ARCHIVE',
        Expires='string',
        CacheControl='string',
        ContentType='string',
        ContentDisposition='string',
        ContentEncoding='string',
        ContentLanguage='string',
        ContentLength='123',
        ContentMD5='string',
        Metadata={
            'x-cos-meta-key1': 'value1',
            'x-cos-meta-key2': 'value2'
        },
        TrafficLimit='1048576'
    )
    
    #.cssg-snippet-body-end

# 简单上传对象
def put_object_comp_comp():
    #.cssg-snippet-body-start:[put-object-comp-comp]
    #### 文件流简单上传（不支持超过5G的文件，推荐使用下方高级上传接口）
    # 强烈建议您以二进制模式(binary mode)打开文件,否则可能会导致错误
    with open('picture.jpg', 'rb') as fp:
        response = client.put_object(
            Bucket='examplebucket-1250000000',
            Body=fp,
            Key='picture.jpg',
            StorageClass='STANDARD',
            EnableMD5=False
        )
    print(response['ETag'])
    
    #### 字节流简单上传
    response = client.put_object(
        Bucket='examplebucket-1250000000',
        Body=b'bytes',
        Key='picture.jpg',
        EnableMD5=False
    )
    print(response['ETag'])
    
    
    #### chunk 简单上传
    import requests
    stream = requests.get('https://cloud.tencent.com/document/product/436/7778')
    
    # 网络流将以 Transfer-Encoding:chunked 的方式传输到 COS
    response = client.put_object(
        Bucket='examplebucket-1250000000',
        Body=stream,
        Key='picture.jpg'
    )
    print(response['ETag'])
    
    #### 高级上传接口（推荐）
    # 根据文件大小自动选择简单上传或分块上传，分块上传具备断点续传功能。
    response = client.upload_file(
        Bucket='examplebucket-1250000000',
        LocalFilePath='local.txt',
        Key='picture.jpg',
        PartSize=1,
        MAXThread=10,
        EnableMD5=False
    )
    print(response['ETag'])
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 简单上传对象
put_object()

# 简单上传对象
put_object_comp()

# 简单上传对象
put_object_comp_comp()

#.cssg-methods-pragma