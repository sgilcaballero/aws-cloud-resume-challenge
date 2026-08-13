export AWS_ACCESS_KEY_ID ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION=us-east-1
SHELL := /bin/bash

## Deploy the infrastructure
deploy:
	@echo "Deploying the infrastructure..."
	cd terraform && lstk tf init && lstk tf plan && lstk tf apply --auto-approve
	@echo "Infrastructure deployed successfully."

## Start LocalStack in detached mode
start:
		@test -n "${LOCALSTACK_AUTH_TOKEN}" || (echo "LOCALSTACK_AUTH_TOKEN is not set. Find your token at https://app.localstack.cloud/workspace/auth-token"; exit 1)
		@LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) lstk start

## Stop the Running LocalStack container
stop:
		@echo
		lstk stop

## Save the logs in a separate file
logs:
		@lstk logs > logs.txt
