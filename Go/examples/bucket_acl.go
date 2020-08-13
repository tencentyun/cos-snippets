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

// 设置存储桶 ACL
func (s *CosTestSuite) putBucketAcl() {
  client := s.Client
  //.cssg-snippet-body-start:[put-bucket-acl]
  // 1. 通过请求头设置 Bucket ACL
  opt := &cos.BucketPutACLOptions{
      Header: &cos.ACLHeaderOptions{
          //private，public-read，public-read-write
          XCosACL: "private",
      },
  }
  _, err := client.Bucket.PutACL(context.Background(), opt)
  if err != nil {
      panic(err)
  }
  
  // 2. 通过请求体设置 Bucket ACL
  opt = &cos.BucketPutACLOptions{
      Body: &cos.ACLXml{
          Owner: &cos.Owner{
              ID: "qcs::cam::uin/100000000001:uin/100000000001",
          },
          AccessControlList: []cos.ACLGrant{
              {
                  Grantee: &cos.ACLGrantee{
                      // Type 备选项 "Group"、"CanonicalUser"
                      Type: "RootAccount",
                      ID:   "qcs::cam::uin/100000760461:uin/100000760461",
                  },
                  // Permission 备选项 "WRITE"、"FULL_CONTROL"
                  Permission: "FULL_CONTROL",
              },
          },
      },
  }
  _, err = client.Bucket.PutACL(context.Background(), opt)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 获取存储桶 ACL
func (s *CosTestSuite) getBucketAcl() {
  client := s.Client
  //.cssg-snippet-body-start:[get-bucket-acl]
  _, _, err := client.Bucket.GetACL(context.Background())
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestBucketACL() {
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

	// 设置存储桶 ACL
	s.putBucketAcl()

	// 获取存储桶 ACL
	s.getBucketAcl()

	//.cssg-methods-pragma
}
