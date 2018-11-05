package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/golang/mock/gomock"
	"github.com/mattjones753/cd-demo/src/db"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestHelloWorld(t *testing.T) {
	t.Run("returns hello, unknown when user not supplied", func(t *testing.T) {
		mockDb := getMockDb(t)
		request := &events.APIGatewayProxyRequest{Path: "/hello"}
		mockDb.EXPECT().Select(gomock.Any()).MaxTimes(0)
		response, err := createHello(mockDb)(request)
		require.Nil(t, err)
		require.Equal(t, events.APIGatewayProxyResponse{Body: "Hello, Unknown", StatusCode: 200}, response)
	})

	t.Run("returns hello, unknown when user in path not found", func(t *testing.T) {
		mockDb := getMockDb(t)
		request := &events.APIGatewayProxyRequest{Path: "/hello/Matthew"}
		mockDb.EXPECT().Select(gomock.Any()).Return(nil, nil)
		response, err := createHello(mockDb)(request)
		require.Nil(t, err)
		require.Equal(t, events.APIGatewayProxyResponse{Body: "Hello, Unknown", StatusCode: 200}, response)
	})

	t.Run("returns hello, <name> when user in path found", func(t *testing.T) {
		request := &events.APIGatewayProxyRequest{Path: "/hello/Matt"}
		mockDb := getMockDb(t)
		mockDb.EXPECT().Select(gomock.Any()).Return(&db.User{Name: "Matt"}, nil)
		response, err := createHello(mockDb)(request)
		require.Nil(t, err)
		require.Equal(t, events.APIGatewayProxyResponse{Body: "Hello, Matt", StatusCode: 200}, response)
	})
}

func getMockDb(t *testing.T) *db.MockDb {
	ctrl := gomock.NewController(t)
	mockDb := db.NewMockDb(ctrl)
	return mockDb
}
