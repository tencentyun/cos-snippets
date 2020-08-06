using COSXML.Auth;
using System;

namespace Name
{

  public class CusteomCredentialProvider {

    //.cssg-snippet-body-start:[custom-credential-provider]
    public class CustomQCloudCredentialProvider : DefaultSessionQCloudCredentialProvider
    {

      public CustomQCloudCredentialProvider(): base(null, null, 0L, null) {
        ;
      }

      public override void Refresh()
      {
        //... 这里通过腾讯云请求临时密钥
        string tmpSecretId = "COS_SECRETID"; //"临时密钥 SecretId";
        string tmpSecretKey = "COS_SECRETKEY"; //"临时密钥 SecretKey";
        string tmpToken = "COS_TOKEN"; //"临时密钥 token";
        long tmpStartTime = 1546861202;//临时密钥有效开始时间，精确到秒
        long tmpExpiredTime = 1546862502;//临时密钥有效截止时间，精确到秒
        // 调用接口更新密钥
        SetQCloudCredential(tmpSecretId, tmpSecretKey, 
          String.Format("{0};{1}", tmpStartTime, tmpExpiredTime), tmpToken);
      }
    }
    //.cssg-snippet-body-end
    
    public void init() {
      QCloudCredentialProvider cosCredentialProvider = new CustomQCloudCredentialProvider();
    }
  }

}