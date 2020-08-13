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

// 恢复归档对象
func (s *CosTestSuite) restoreObject() {
  client := s.Client
  //.cssg-snippet-body-start:[restore-object]
  key := "example_restore"
  f, err := os.Open("../test")
  if err != nil {
      panic(err)
  }
  opt := &cos.ObjectPutOptions{
      ObjectPutHeaderOptions: &cos.ObjectPutHeaderOptions{
          ContentType:      "text/html",
          XCosStorageClass: "ARCHIVE", //归档类型
      },
      ACLHeaderOptions: &cos.ACLHeaderOptions{
          // 如果不是必要操作，建议上传文件时不要给单个文件设置权限，避免达到限制。若不设置默认继承桶的权限。
          XCosACL: "private",
      },
  }
  // 归档直传
  _, err = client.Object.Put(context.Background(), key, f, opt)
  if err != nil {
      panic(err)
  }
  
  opts := &cos.ObjectRestoreOptions{
      Days: 2,
      Tier: &cos.CASJobParameters{
          // Standard, Exepdited and Bulk
          Tier: "Expedited",
      },
  }
  // 归档恢复
  _, err = client.Object.PostRestore(context.Background(), key, opts)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestRestoreObject() {
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

	// 恢复归档对象
	s.restoreObject()

	//.cssg-methods-pragma
}
