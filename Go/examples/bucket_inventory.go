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

// 设置存储桶清单任务
func (s *CosTestSuite) putBucketInventory() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-inventory]
  opt := &cos.BucketPutInventoryOptions{
      ID: "test_id",
      // True or False
      IsEnabled:              "True",
      IncludedObjectVersions: "All",
      Filter: &cos.BucketInventoryFilter{
          Prefix: "test",
      },
      OptionalFields: &cos.BucketInventoryOptionalFields{
          BucketInventoryFields: []string{
              "Size", "LastModifiedDate",
          },
      },
      Schedule: &cos.BucketInventorySchedule{
          // Weekly or Daily
          Frequency: "Daily",
      },
      Destination: &cos.BucketInventoryDestination{
          Bucket: dBucket,
          Format: "CSV",
      },
  }
  resp, err := client.Bucket.PutInventory(context.Background(), id, opt)
  
  //.cssg-snippet-body-end
}

// 获取存储桶清单任务
func (s *CosTestSuite) getBucketInventory() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-inventory]
  v, response, err := client.Bucket.GetInventory(context.Background(), id)
  
  //.cssg-snippet-body-end
}

// 列出所有存储桶清单任务
func (s *CosTestSuite) listBucketInventory() {
  client := s.Client
  //.cssg-snippet-body-start:[list-bucket-inventory]
  v, resp, err := client.Bucket.ListInventoryConfigurations(context.Background(), "")
  
  //.cssg-snippet-body-end
}

// 删除存储桶清单任务
func (s *CosTestSuite) deleteBucketInventory() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-bucket-inventory]
  resp, err = client.Bucket.DeleteInventory(context.Background(), "test_id")
  
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketInventory() {
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

	// 设置存储桶清单任务
	s.putBucketInventory()

	// 获取存储桶清单任务
	s.getBucketInventory()

	// 列出所有存储桶清单任务
	s.listBucketInventory()

	// 删除存储桶清单任务
	s.deleteBucketInventory()

	//.cssg-methods-pragma
}
