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

// 设置存储桶标签
func (s *CosTestSuite) putBucketTagging() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-tagging]
  opt := &cos.BucketPutTaggingOptions{
      TagSet: []cos.BucketTaggingTag{
      {   
          Key:   "testk1",
          Value: "testv1",
      },  
      {   
          Key:   "testk2",
          Value: "testv2",
      },  
      },  
  }   
  resp, err := client.Bucket.PutTagging(context.Background(), opt)
  
  //.cssg-snippet-body-end
}

// 获取存储桶标签
func (s *CosTestSuite) getBucketTagging() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-tagging]
  v, resp, err := client.Bucket.GetTagging(context.Background())
  
  //.cssg-snippet-body-end
}

// 删除存储桶标签
func (s *CosTestSuite) deleteBucketTagging() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-bucket-tagging]
  func (s *BucketService) DeleteTagging(ctx context.Context) (*Response, error)
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketTagging() {
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

	// 设置存储桶标签
	s.putBucketTagging()

	// 获取存储桶标签
	s.getBucketTagging()

	// 删除存储桶标签
	s.deleteBucketTagging()

	//.cssg-methods-pragma
}
