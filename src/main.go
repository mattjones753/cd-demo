package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"path"
	"regexp"
)

func helloWorld(request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	name := "World"
	if uri := request.Path; regexp.MustCompile("/hello/.+").MatchString(uri) {
		name = path.Base(uri)
	}
	return events.APIGatewayProxyResponse{StatusCode: 200, Body: fmt.Sprintf("Hello, %v", name)}, nil
}

func main() {
	lambda.Start(helloWorld)
}
