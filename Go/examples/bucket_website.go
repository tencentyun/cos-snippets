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

// 设置存储桶静态网站
func (s *CosTestSuite) putBucketWebsite() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-website]
  opt := &cos.BucketPutWebsiteOptions{
      Index: "index.html",
      Error: &cos.ErrorDocument{"index_backup.html"},
      RoutingRules: &cos.WebsiteRoutingRules{
          []cos.WebsiteRoutingRule{
          {   
              ConditionErrorCode: "404",
              RedirectProtocol:   "https",
              RedirectReplaceKey: "404.html",
          },  
          {   
              ConditionPrefix:          "docs/",
              RedirectProtocol:         "https",
              RedirectReplaceKeyPrefix: "documents/",
          },  
          },  
      },  
  }   
  resp, err := client.Bucket.PutWebsite(context.Background(), opt)
  
  //.cssg-snippet-body-end
}

// 获取存储桶静态网站
func (s *CosTestSuite) getBucketWebsite() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-website]
  res, rsp, err := client.Bucket.GetWebsite(context.Background())
  
  //.cssg-snippet-body-end
}

// 删除存储桶静态网站
func (s *CosTestSuite) deleteBucketWebsite() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-bucket-website]
  resp, err = s.Client.Bucket.DeleteWebsite(context.Background())
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketWebsite() {
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

	// 设置存储桶静态网站
	s.putBucketWebsite()

	// 获取存储桶静态网站
	s.getBucketWebsite()

	// 删除存储桶静态网站
	s.deleteBucketWebsite()

	//.cssg-methods-pragma
}
