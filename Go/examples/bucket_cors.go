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

// 设置存储桶跨域规则
func (s *CosTestSuite) putBucketCors() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-cors]
  opt := &cos.BucketPutCORSOptions{
      Rules: []cos.BucketCORSRule{
          {
              AllowedOrigins: []string{"http://www.qq.com"},
              AllowedMethods: []string{"PUT", "GET"},
              AllowedHeaders: []string{"x-cos-meta-test", "x-cos-xx"},
              MaxAgeSeconds:  500,
              ExposeHeaders:  []string{"x-cos-meta-test1"},
          },
          {
              ID:             "1234",
              AllowedOrigins: []string{"http://www.baidu.com", "twitter.com"},
              AllowedMethods: []string{"PUT", "GET"},
              MaxAgeSeconds:  500,
          },
      },
  }
  _, err := client.Bucket.PutCORS(context.Background(), opt)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 获取存储桶跨域规则
func (s *CosTestSuite) getBucketCors() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-cors]
  _, _, err := client.Bucket.GetCORS(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 删除存储桶跨域规则
func (s *CosTestSuite) deleteBucketCors() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-bucket-cors]
  _, err := client.Bucket.DeleteCORS(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketCORS() {
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

	// 设置存储桶跨域规则
	s.putBucketCors()

	// 获取存储桶跨域规则
	s.getBucketCors()

	// 删除存储桶跨域规则
	s.deleteBucketCors()

	//.cssg-methods-pragma
}
