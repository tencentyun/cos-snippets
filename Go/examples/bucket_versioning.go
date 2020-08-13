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

// 设置存储桶多版本
func (s *CosTestSuite) putBucketVersioning() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-versioning]
  opt := &cos.BucketPutVersionOptions{
      // Enabled 或者 Suspended, 版本控制配置一旦开启就不能删除，只能暂停
      Status: "Enabled",
  }
  _, err := client.Bucket.PutVersioning(context.Background(), opt)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 获取存储桶多版本状态
func (s *CosTestSuite) getBucketVersioning() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-versioning]
  _, _, err := client.Bucket.GetVersioning(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketVersioning() {
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

	// 设置存储桶多版本
	s.putBucketVersioning()

	// 获取存储桶多版本状态
	s.getBucketVersioning()

	//.cssg-methods-pragma
}
