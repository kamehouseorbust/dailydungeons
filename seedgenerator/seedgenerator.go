package main

import (
	"context"
	"fmt"
	"math/rand"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func generateSeed(n int) string {
	sb := strings.Builder{}
	sb.Grow(n)
	for i := 0; i < n; i++ {
		sb.WriteByte(charset[rand.Intn(len(charset))])
	}
	return sb.String()
}

func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	rand.Seed(time.Now().UnixNano())
	return fmt.Sprintf("Seed: %s", generateSeed(20)), nil
}

func main() {
	lambda.Start(HandleRequest)
}
