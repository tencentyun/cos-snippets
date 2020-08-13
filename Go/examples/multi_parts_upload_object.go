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

// 初始化分片上传
func (s *CosTestSuite) initMultiUpload() {
  client := s.Client
  //.cssg-snippet-body-start:[init-multi-upload]
  name := "exampleobject"
  // 可选opt,如果不是必要操作，建议上传文件时不要给单个文件设置权限，避免达到限制。若不设置默认继承桶的权限。
  v, _, err := client.Object.InitiateMultipartUpload(context.Background(), name, nil)
  if err != nil {
      panic(err)
  }
  UploadID = v.UploadID
  
  //.cssg-snippet-body-end
}

// 列出所有未完成的分片上传任务
func (s *CosTestSuite) listMultiUpload() {
  client := s.Client
  //.cssg-snippet-body-start:[list-multi-upload]
  _, _, err := client.Bucket.ListMultipartUploads(context.Background(), nil)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 上传一个分片
func (s *CosTestSuite) uploadPart() {
  client := s.Client
  //.cssg-snippet-body-start:[upload-part]
  // 注意，上传分块的块数最多10000块
  key := "exampleobject"
  f := strings.NewReader("test hello")
  // opt可选
  resp, err := client.Object.UploadPart(
      context.Background(), key, UploadID, 1, f, nil,
  )
  if err != nil {
      panic(err)
  }
  PartETag = resp.Header.Get("ETag")
  
  //.cssg-snippet-body-end
}

// 列出已上传的分片
func (s *CosTestSuite) listParts() {
  client := s.Client
  //.cssg-snippet-body-start:[list-parts]
  key := "exampleobject"
  _, _, err := client.Object.ListParts(context.Background(), key, UploadID, nil)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 完成分片上传任务
func (s *CosTestSuite) completeMultiUpload() {
  client := s.Client
  //.cssg-snippet-body-start:[complete-multi-upload]
  // 完成分块上传
  key := "exampleobject"
  uploadID := UploadID
  
  opt := &cos.CompleteMultipartUploadOptions{}
  opt.Parts = append(opt.Parts, cos.Object{
      PartNumber: 1, ETag: PartETag},
  )
  
  _, _, err := client.Object.CompleteMultipartUpload(
      context.Background(), key, uploadID, opt,
  )
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestMultiPartsUploadObject() {
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

	// 初始化分片上传
	s.initMultiUpload()

	// 列出所有未完成的分片上传任务
	s.listMultiUpload()

	// 上传一个分片
	s.uploadPart()

	// 列出已上传的分片
	s.listParts()

	// 完成分片上传任务
	s.completeMultiUpload()

	//.cssg-methods-pragma
}
