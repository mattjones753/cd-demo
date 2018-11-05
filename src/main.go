package main

import (
	"fmt"
	"github.com/River-Island/pgw-gopkgs/envs"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/mattjones753/cd-demo/src/db"
	"path"
	"regexp"
)

func createHello(database db.Db) func(request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return func(request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		greetingName := "Unknown"
		if uri := request.Path; regexp.MustCompile("/hello/.+").MatchString(uri) {
			username := path.Base(uri)
			user, err := database.Select(username)
			if err != nil {
				return events.APIGatewayProxyResponse{StatusCode: 500}, err
			}
			if user != nil && user.Name != "" {
				greetingName = user.Name
			}
		}
		return events.APIGatewayProxyResponse{StatusCode: 200, Body: fmt.Sprintf("Hello, %v", greetingName)}, nil
	}
}

func main() {
	dbUser := envs.MustGetEnv("DATABASE_USER")
	dbPass := envs.MustGetEnv("DATABASE_PASSWORD")
	dbHost := envs.MustGetEnv("DATABASE_ENDPOINT")
	dbName := envs.MustGetEnv("DATABASE_NAME")
	database := db.NewDb(dbUser, dbHost, dbPass, dbName)
	lambda.Start(createHello(database))
}
