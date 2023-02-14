package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type Seed struct {
	Date string `json:"date"`
	Seed int    `json:"seed"`
}

const tableName string = "dailySeeds"

func generateSeed() int {
	return rand.Intn(9223372036854775807)
}

func HandleRequest(ctx context.Context) (string, error) {
	rand.Seed(time.Now().UnixNano())

	// Initialize a session that the SDK will use to load
	// credentials from the shared credentials file ~/.aws/credentials
	// and region from the shared configuration file ~/.aws/config.
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	// Create dynamoDB client
	svc := dynamodb.New(sess)

	// Create seed item
	seedItem := Seed{
		Date: time.Now().Format("01-02-2006"),
		Seed: generateSeed(),
	}
	// Marshal for put operation
	av, err := dynamodbattribute.MarshalMap(seedItem)
	if err != nil {
		log.Fatalf("There was an error marshalling new seed item: %s", err)
	}
	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(tableName),
	}
	// Put item to table
	_, err = svc.PutItem(input)
	if err != nil {
		log.Fatalf("Got error putting item to dynamoDB: %s", err)
	}
	fmt.Printf("Successfully added seed: %d for date: %s", seedItem.Seed, seedItem.Date)

	return fmt.Sprintf("Seed: %d", seedItem.Seed), nil
}

func main() {
	lambda.Start(HandleRequest)
}
