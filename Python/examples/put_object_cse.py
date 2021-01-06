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

# 使用 AES256 进行客户端加密
def put_object_cse_c_aes():
    #.cssg-snippet-body-start:[put-object-cse-c-aes]
    # 初始化用户身份信息(SECRET_ID, SECRET_KEY)
    SECRET_ID = "COS_SECRETID"
    SECRET_KEY = "COS_SECRETKEY"
    REGION = "COS_REGION"
    conf = CosConfig(
        Region=REGION,
        SecretId=SECRET_ID,
        SecretKey=SECRET_KEY,
    )
    
    # 方式一：通过密钥值初始化加密客户端
    aes_provider = AESProvider(aes_key='aes_key_value')
    
    # 方式二：通过密钥路径初始化加密客户端
    aes_key_pair = AESProvider(aes_key_path='aes_key_path')
    
    client_for_aes = CosEncryptionClient(conf, aes_provider)
    
    # 上传对象，兼容非加密客户端的put_object的所有功能，具体使用可参考put_object
    response = client_for_aes.put_object(
                            Bucket='examplebucket-1250000000',
                            Body=b'bytes'|file,
                            Key='exampleobject',
                            EnableMD5=False)
    
    # 下载对象，兼容非加密客户端的get_object的所有功能，具体使用可参考get_object
    response = client_for_aes.get_object(
                            Bucket='examplebucket-1250000000',
                            Key='exampleobject')
    
    # 分片上传，兼容非加密客户端的分片上传，除了最后一个part，每个part的大小必须为16字节的整数倍
    response = client_for_aes.create_multipart_upload(
                            Bucket='examplebucket-1250000000',
                            Key='exampleobject_upload')
    uploadid = response['UploadId']
    client_for_aes.upload_part(
                    Bucket='examplebucket-1250000000',
                    Key='exampleobject_upload',
                    Body=b'bytes'|file,
                    PartNumber=1,
                    UploadId=uploadid)
    response = client_for_aes.list_parts(
                    Bucket='examplebucket-1250000000',
                    Key='exampleobject_upload',
                    UploadId=uploadid)
    client_for_aes.complete_multipart_upload(
                    Bucket='examplebucket-1250000000',
                    Key='exampleobject_upload',
                    UploadId=uploadid,
                    MultipartUpload={'Part':response['Part']})
    
    # 断点续传方式上传对象，`partsize`大小必须为16字节的整数倍
    response = client_for_aes.upload_file(
        Bucket='test04-123456789',
        LocalFilePath='local.txt',
        Key=file_name,
        PartSize=10,
        MAXThread=10
    )
    
    
    #.cssg-snippet-body-end

# 使用 RSA 进行客户端加密
def put_object_cse_c_rsa():
    #.cssg-snippet-body-start:[put-object-cse-c-rsa]
    # 初始化用户身份信息(SECRET_ID, SECRET_KEY)
    SECRET_ID = "COS_SECRETID"
    SECRET_KEY = "COS_SECRETKEY"
    REGION = "COS_REGION"
    conf = CosConfig(
        Region=REGION,
        SecretId=SECRET_ID,
        SecretKey=SECRET_KEY,
    )
    
    # 方式一：通过密钥值初始化加密客户端
    rsa_key_pair = RSAProvider.get_rsa_key_pair('public_key_value', 'private_key_value')
    
    # 方式二：通过密钥路径初始化加密客户端
    rsa_key_pair = RSAProvider.get_rsa_key_pair('public_key_path', 'private_key_path')
    
    rsa_provider = RSAProvider(key_pair_info=rsa_key_pair)
    client_for_rsa = CosEncryptionClient(conf, rsa_provider)
    
    # 上传对象，兼容非加密客户端的put_object的所有功能，具体使用可参考put_object
    response = client_for_rsa.put_object(
                            Bucket='examplebucket-1250000000',
                            Body=b'bytes'|file,
                            Key='exampleobject',
                            EnableMD5=False)
    
    # 下载对象，兼容非加密客户端的get_object的所有功能，具体使用可参考get_object
    response = client_for_rsa.get_object(
                            Bucket='examplebucket-1250000000',
                            Key='exampleobject')
    
    # 分片上传，兼容非加密客户端的分片上传，除了最后一个part，每个part的大小必须为16字节的整数倍
    response = client_for_rsa.create_multipart_upload(
                            Bucket='examplebucket-1250000000',
                            Key='exampleobject_upload')
    uploadid = response['UploadId']
    client_for_rsa.upload_part(
                    Bucket='examplebucket-1250000000',
                    Key='exampleobject_upload',
                    Body=b'bytes'|file,
                    PartNumber=1,
                    UploadId=uploadid)
    response = client_for_rsa.list_parts(
                    Bucket='examplebucket-1250000000',
                    Key='exampleobject_upload',
                    UploadId=uploadid)
    client_for_rsa.complete_multipart_upload(
                    Bucket='examplebucket-1250000000',
                    Key='exampleobject_upload',
                    UploadId=uploadid,
                    MultipartUpload={'Part':response['Part']})
    
    # 断点续传方式上传对象，`partsize`大小必须为16字节的整数倍
    response = client_for_rsa.upload_file(
        Bucket='test04-123456789',
        LocalFilePath='local.txt',
        Key=file_name,
        PartSize=10,
        MAXThread=10
    )
    
    #.cssg-snippet-body-end

#.cssg-methods-pragma


# 使用 AES256 进行客户端加密
put_object_cse_c_aes()

# 使用 RSA 进行客户端加密
put_object_cse_c_rsa()

#.cssg-methods-pragma