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

// 下载对象
func (s *CosTestSuite) getObject() {
  client := s.Client
  //.cssg-snippet-body-start:[get-object]
  key := "exampleobject"
  opt := &cos.ObjectGetOptions{
      ResponseContentType: "text/html",
      Range:               "bytes=0-3",
  }
  // opt 可选，无特殊设置可设为 nil
  // 1. 从响应体中获取对象
  resp, err := client.Object.Get(context.Background(), key, opt)
  if err != nil {
      panic(err)
  }
  ioutil.ReadAll(resp.Body)
  resp.Body.Close()
  
  // 2. 下载对象到本地文件
  _, err = client.Object.GetToFile(context.Background(), key, "example.txt", nil)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestGetObject() {
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

	// 下载对象
	s.getObject()

	//.cssg-methods-pragma
}
