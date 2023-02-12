package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type Seed struct {
	Date string `json:"date"`
	Seed string `json:"seed"`
}

const tableName string = "dailySeeds"

func HandleRequest(ctx context.Context) (Seed, error) {
	// We are technically using yesterday's seed to avoid date overlapping
	date := time.Now().AddDate(0, 0, -1).Format("01-02-2006")

	// Initialize a session that the SDK will use to load
	// credentials from the shared credentials file ~/.aws/credentials
	// and region from the shared configuration file ~/.aws/config.
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	// Create dynamoDB client
	svc := dynamodb.New(sess)

	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"date": {
				S: aws.String(date),
			},
		},
	})

	if err != nil {
		log.Fatal("There was an error retrieving today's seed", err)
	}

	if result.Item == nil {
		msg := "Could not find a seed for today's date"
		return Seed{}, errors.New(msg)
	}

	item := Seed{}

	err = dynamodbattribute.UnmarshalMap(result.Item, &item)
	if err != nil {
		panic(fmt.Sprintf("Failed to unmarshal record, %v", err))
	}

	fmt.Println("Found seed:")
	fmt.Println("Date: ", item.Date)
	fmt.Println("Seed: ", item.Seed)

	return item, nil
}

func main() {
	lambda.Start(HandleRequest)
}
