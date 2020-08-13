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

// 设置存储桶生命周期
func (s *CosTestSuite) putBucketLifecycle() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-lifecycle]
  lc := &cos.BucketPutLifecycleOptions{
      Rules: []cos.BucketLifecycleRule{
          {
              ID:     "1234",
              Filter: &cos.BucketLifecycleFilter{Prefix: "test"},
              Status: "Enabled",
              Transition: &cos.BucketLifecycleTransition{
                  Days:         10,
                  StorageClass: "Standard",
              },
          },
          {
              ID:     "123422",
              Filter: &cos.BucketLifecycleFilter{Prefix: "gg"},
              Status: "Disabled",
              Expiration: &cos.BucketLifecycleExpiration{
                  Days: 10,
              },
          },
      },
  }
  _, err := client.Bucket.PutLifecycle(context.Background(), lc)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 获取存储桶生命周期
func (s *CosTestSuite) getBucketLifecycle() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-lifecycle]
  _, _, err := client.Bucket.GetLifecycle(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 删除存储桶生命周期
func (s *CosTestSuite) deleteBucketLifecycle() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-bucket-lifecycle]
  _, err := client.Bucket.DeleteLifecycle(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketLifecycle() {
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

	// 设置存储桶生命周期
	s.putBucketLifecycle()

	// 获取存储桶生命周期
	s.getBucketLifecycle()

	// 删除存储桶生命周期
	s.deleteBucketLifecycle()

	//.cssg-methods-pragma
}
