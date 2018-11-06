package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/mattjones753/cd-demo/src/db"
	"log"
	"math"
	"os"
	"path"
	"regexp"
	"time"
)

func createHello(database db.Db) func(request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return func(request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		birthdayCountdownOn := os.Getenv("ENABLE_BIRTHDAY_COUNTDOWN") == "true"
		greetingName := "Unknown"
		greetingDaysTillBirthday := "don't know how many"
		if uri := request.Path; regexp.MustCompile("/hello/.+").MatchString(uri) {
			username := path.Base(uri)
			user, err := database.Select(username)
			if err != nil {
				return events.APIGatewayProxyResponse{StatusCode: 500}, err
			}
			if user != nil && user.Name != "" {
				greetingName = user.Name
				if birthdayCountdownOn {
					greetingDaysTillBirthday = fmt.Sprintf("it's %d", daysUntilDate(user.DateOfBirth))
				}
			}
		}
		message := fmt.Sprintf("Hello, %v", greetingName)
		if birthdayCountdownOn {
			message = fmt.Sprintf("Hello, %v, %v days till your birthday!", greetingName, greetingDaysTillBirthday)
		}
		return events.APIGatewayProxyResponse{StatusCode: 200, Body: message}, nil
	}
}

func daysUntilDate(date time.Time) int {
	now := time.Now()
	birthdayThisYear := time.Date(now.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())

	if now.Before(birthdayThisYear) {
		return int(math.Ceil(birthdayThisYear.Sub(now).Hours() / 24))
	} else {
		return int(math.Ceil(birthdayThisYear.AddDate(1, 0, 0).Sub(now).Hours() / 24))
	}
}

func main() {
	dbUser := mustGetEnv("DATABASE_USER")
	dbPass := mustGetEnv("DATABASE_PASSWORD")
	dbHost := mustGetEnv("DATABASE_ENDPOINT")
	dbName := mustGetEnv("DATABASE_NAME")
	database := db.NewDb(dbUser, dbHost, dbPass, dbName)
	fmt.Println(createHello(database)(&events.APIGatewayProxyRequest{Path: "/hello/matt"}))
}

// mustGetEnv stops a process if it can't get an environment variable
func mustGetEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("ENV VAR %q NOT SET", key)
	}

	return v
}
