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

// 删除对象
func (s *CosTestSuite) deleteObject() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-object]
  key := "exampleobject"
  _, err := client.Object.Delete(context.Background(), key)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 删除多个对象
func (s *CosTestSuite) deleteMultiObject() {
  client := s.Client
  //.cssg-snippet-body-start:[delete-multi-object]
  var objects []string
  objects = append(objects, []string{"a", "b", "c"}...)
  obs := []cos.Object{}
  for _, v := range objects {
      obs = append(obs, cos.Object{Key: v})
  }
  opt := &cos.ObjectDeleteMultiOptions{
      Objects: obs,
      // 布尔值，这个值决定了是否启动 Quiet 模式
      // 值为 true 启动 Quiet 模式，值为 false 则启动 Verbose 模式，默认值为 false
      // Quiet: true,
  }
  
  _, _, err := client.Object.DeleteMulti(context.Background(), opt)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestDeleteObject() {
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

	// 删除对象
	s.deleteObject()

	// 删除多个对象
	s.deleteMultiObject()

	//.cssg-methods-pragma
}
