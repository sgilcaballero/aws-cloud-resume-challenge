export AWS_ACCESS_KEY_ID ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION=us-east-1

# Dynamically locate the samlocal executable on Windows at runtime (bypasses absolute paths)
SAMLOCAL := $(shell for /f "delims=" %%i in ('where samlocal.bat') do @echo %%i& exit)

## Deploy Front-end with Terraform & Back-end with SAM
deploy:
	@echo "Deploying Front-end via Terraform..."
	cd terraform && lstk tf init && lstk tf plan && lstk tf apply --auto-approve
	@echo "Creating LocalStack SAM Staging Bucket..."
	-lstk aws s3 mb s3://localstack-sam-staging-bucket --region us-east-1
	@echo "Deploying Backend Serverless Stack via SAM..."
	cd backend && "$(SAMLOCAL)" build && "$(SAMLOCAL)" deploy --stack-name resume-backend --no-confirm-changeset --s3-bucket localstack-sam-staging-bucket
	@echo "All Infrastructure deployed successfully."

## Destroy commands
destroy-frontend:
	@echo "Destroying Frontend via Terraform..."
	cd terraform && lstk tf destroy --auto-approve
	@echo "Frontend destroyed successfully."

destroy-backend:
	@echo "Destroying Backend Serverless Stack via SAM..."
	"$(SAMLOCAL)" delete --stack-name resume-backend --no-prompts
	-lstk aws s3 rb s3://localstack-sam-staging-bucket --force
	@echo "Backend destroyed successfully."

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
