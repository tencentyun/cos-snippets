cd cases
goimports -l -w *.go
go test service_test.go -v
go test init_sts_test.go -v
go test bucket_test.go -v
go test object_test.go -v
cd ../example
go run get_service_comp.go
go run put_bucket_comp.go
go run get_bucket_comp.go
go run put_object_comp.go
go run get_object_comp.go
go run delete_object_comp.go
go run ../delete_bucket.go