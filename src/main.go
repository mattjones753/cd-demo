package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/mattjones753/cd-demo/src/db"
	"log"
	"os"
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
	dbUser := mustGetEnv("DATABASE_USER")
	dbPass := mustGetEnv("DATABASE_PASSWORD")
	dbHost := mustGetEnv("DATABASE_ENDPOINT")
	dbName := mustGetEnv("DATABASE_NAME")
	database := db.NewDb(dbUser, dbHost, dbPass, dbName)
	lambda.Start(createHello(database))
}

// mustGetEnv stops a process if it can't get an environment variable
func mustGetEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("ENV VAR %q NOT SET", key)
	}

	return v
}
