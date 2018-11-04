package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestHelloWorld(t *testing.T) {
	t.Run("returns hello, world by default", func(t *testing.T) {
		request := &events.APIGatewayProxyRequest{Path: "/hello"}
		response, err := helloWorld(request)
		require.Nil(t, err)
		require.Equal(t, events.APIGatewayProxyResponse{Body: "Hello, World", StatusCode: 200}, response)
	})

	t.Run("returns hello, <name> when in path", func(t *testing.T) {
		request := &events.APIGatewayProxyRequest{Path: "/hello/Matt"}
		response, err := helloWorld(request)
		require.Nil(t, err)
		require.Equal(t, events.APIGatewayProxyResponse{Body: "Hello, Matt", StatusCode: 200}, response)
	})
}
