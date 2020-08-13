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

// 设置存储桶跨地域复制规则
func (s *CosTestSuite) putBucketReplication() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-replication]
  opt := &cos.PutBucketReplicationOptions{
      // qcs::cam::uin/[UIN]:uin/[Subaccount]
      Role: "qcs::cam::uin/100000760461:uin/100000760461",
      Rule: []cos.BucketReplicationRule{
          {
              ID: "1",
              // Enabled or Disabled
              Status: "Enabled",
              Destination: &cos.ReplicationDestination{
                  // qcs::cos:[Region]::[Bucketname-Appid]
                  Bucket: "qcs::cos:ap-beijing::destinationbucket-1250000000",
              },
          },
      },
  }
  _, err := client.Bucket.PutBucketReplication(context.Background(), opt)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 获取存储桶跨地域复制规则
func (s *CosTestSuite) getBucketReplication() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-replication]
  _, _, err := client.Bucket.GetBucketReplication(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 删除存储桶跨地域复制规则
func (s *CosTestSuite) deleteBucketReplication() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-bucket-replication]
  _, err := client.Bucket.DeleteBucketReplication(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketReplication() {
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

	// 设置存储桶跨地域复制规则
	s.putBucketReplication()

	// 获取存储桶跨地域复制规则
	s.getBucketReplication()

	// 删除存储桶跨地域复制规则
	s.deleteBucketReplication()

	//.cssg-methods-pragma
}
