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

// 设置对象 ACL
func (s *CosTestSuite) putObjectAcl() {
  client := s.Client
  //.cssg-snippet-body-start:[put-object-acl]
  // 1.通过请求头设置
  opt := &cos.ObjectPutACLOptions{
      Header: &cos.ACLHeaderOptions{
          XCosACL: "private",
      },
  }
  key := "exampleobject"
  _, err := client.Object.PutACL(context.Background(), key, opt)
  if err != nil {
      panic(err)
  }
  // 2.通过请求体设置
  opt = &cos.ObjectPutACLOptions{
      Body: &cos.ACLXml{
          Owner: &cos.Owner{
              ID: "qcs::cam::uin/100000000001:uin/100000000001",
          },
          AccessControlList: []cos.ACLGrant{
              {
                  Grantee: &cos.ACLGrantee{
                      Type: "RootAccount",
                      ID:   "qcs::cam::uin/100000760461:uin/100000760461",
                  },
  
                  Permission: "FULL_CONTROL",
              },
          },
      },
  }
  
  _, err = client.Object.PutACL(context.Background(), key, opt)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

// 获取对象 ACL
func (s *CosTestSuite) getObjectAcl() {
  client := s.Client
  //.cssg-snippet-body-start:[get-object-acl]
  key := "exampleobject"
  _, _, err := client.Object.GetACL(context.Background(), key)
  if err != nil {
      panic(err)
  }
  
  //.cssg-snippet-body-end
}

//.cssg-methods-pragma


func TestCOSTestSuite(t *testing.T) {
	suite.Run(t, new(CosTestSuite))
}

func (s *CosTestSuite) TestObjectACL() {
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

	// 设置对象 ACL
	s.putObjectAcl()

	// 获取对象 ACL
	s.getObjectAcl()

	//.cssg-methods-pragma
}
