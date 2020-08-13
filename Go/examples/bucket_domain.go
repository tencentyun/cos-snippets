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

// 设置存储桶自定义域名
func (s *CosTestSuite) putBucketDomain() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-domain]
  opt := &cos.BucketPutDomainOptions{
      Status:            "ENABLED",
      Name:              "www.example.com",
      Type:              "REST",
      ForcedReplacement: "CNAME",
  }   
  resp, err := c.Bucket.PutDomain(context.Background(), opt)
  
  //.cssg-snippet-body-end
}

// 获取存储桶自定义域名
func (s *CosTestSuite) getBucketDomain() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-domain]
  v, resp, err := c.Bucket.GetDomain(context.Background())
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketDomain() {
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

	// 设置存储桶自定义域名
	s.putBucketDomain()

	// 获取存储桶自定义域名
	s.getBucketDomain()

	//.cssg-methods-pragma
}
