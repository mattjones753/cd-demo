all: dep test build

build:
	mkdir -p bin
	GOOS=linux CGO_ENABLED=0 go build -o ./bin/hello_world ./src
	zip -qj ./bin/hello_world.zip ./bin/*;

test:
	go test ./... -timeout 10s

dep:
	go get -u github.com/golang/dep/cmd/dep
	dep ensure
