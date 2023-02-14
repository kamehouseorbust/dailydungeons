# Get Daily Seed Lambda

## Introduction

This lambda creates a random string of 20 characters and adds a new entry to a dynamoDB table once per day.

## Setup & Build

* [Install latest version of go](https://go.dev/doc/install)
* Build & Package
  * `GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main getdailyseed.go`
  * `zip main.zip main`
* Upload through AWS with .zip file

## ToDo List

* ~~Implement read from dynamoDB~~
* Create build script for lambda
* Write tests
* Create CI/CD pipeline that tests, builds, packages, and uploads lambda to S3
  * Connect lambda to S3
