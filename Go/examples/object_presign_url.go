package cos

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"github.com/tencentyun/cos-go-sdk-v5"
)

type CosTestSuite struct {
	suite.Suite
	VariableThatShouldStartAtFive int

	// CI client
	Client *cos.Client

	// Copy source client
	CClient *cos.Client

	// test_object
	TestObject string

	// special_file_name
	SepFileName string
}

var (
	UploadID string
	PartETag string
)

// 获取预签名下载链接
func (s *CosTestSuite) getPresignDownloadUrl() {
  client := s.Client
  //.cssg-snippet-body-start:[get-presign-download-url]
  ak := "COS_SECRETID"
  sk := "COS_SECRETKEY"
  name := "exampleobject"
  ctx := context.Background()
  // 1. 通过普通方式下载对象
  resp, err := client.Object.Get(ctx, name, nil)
  if err != nil {
      panic(err)
  }
  bs, _ := ioutil.ReadAll(resp.Body)
  resp.Body.Close()
  // 获取预签名URL
  presignedURL, err := client.Object.GetPresignedURL(ctx, http.MethodGet, name, ak, sk, time.Hour, nil)
  if err != nil {
      panic(err)
  }
  // 2. 通过预签名URL下载对象
  resp2, err := http.Get(presignedURL.String())
  if err != nil {
      panic(err)
  }
  bs2, _ := ioutil.ReadAll(resp2.Body)
  resp2.Body.Close()
  if bytes.Compare(bs2, bs) != 0 {
      panic(errors.New("content is not consistent"))
  }
  
  //.cssg-snippet-body-end
}

// 获取预签名上传链接
func (s *CosTestSuite) getPresignUploadUrl() {
  client := s.Client
  //.cssg-snippet-body-start:[get-presign-upload-url]
  ak := "COS_SECRETID"
  sk := "COS_SECRETKEY"
  
  name := "exampleobject"
  ctx := context.Background()
  f := strings.NewReader("test")
  
  // 1. 通过普通方式上传对象
  _, err := client.Object.Put(ctx, name, f, nil)
  if err != nil {
      panic(err)
  }
  // 获取预签名URL
  presignedURL, err := client.Object.GetPresignedURL(ctx, http.MethodPut, name, ak, sk, time.Hour, nil)
  if err != nil {
      panic(err)
  }
  // 2. 通过预签名方式上传对象
  data := "test upload with presignedURL"
  f = strings.NewReader(data)
  req, err := http.NewRequest(http.MethodPut, presignedURL.String(), f)
  if err != nil {
      panic(err)
  }
  // 用户可自行设置请求头部
  req.Header.Set("Content-Type", "text/html")
  _, err = http.DefaultClient.Do(req)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestObjectPresignUrl() {
	// 将 examplebucket-1250000000 和 ap-guangzhou 修改为真实的信息
	u, _ := url.Parse("https://examplebucket-1250000000.cos.ap-guangzhou.myqcloud.com")
	b := &cos.BaseURL{BucketURL: u}
	c := cos.NewClient(b, &http.Client{
		Transport: &cos.AuthorizationTransport{
			SecretID:  os.Getenv("COS_KEY"),
			SecretKey: os.Getenv("COS_SECRET"),
		},
	})
  s.Client = c

	// 获取预签名下载链接
	s.getPresignDownloadUrl()

	// 获取预签名上传链接
	s.getPresignUploadUrl()

	//.cssg-methods-pragma
}
