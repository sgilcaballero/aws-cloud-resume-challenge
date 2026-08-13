export AWS_ACCESS_KEY_ID ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION=us-east-1

## Deploy everything (Front-end with Terraform, Back-end with SAM)
deploy:
	@echo "Deploying Front-end via Terraform..."
	cd terraform && lstk tf init && lstk tf plan && lstk tf apply --auto-approve
	@echo "Creating LocalStack SAM Staging Bucket..."
	-lstk aws s3 mb s3://localstack-sam-staging-bucket --region us-east-1
	@echo "Deploying Backend Serverless Stack via SAM..."
	cd backend && "C:\Users\sergi\AppData\Roaming\Python\Python314\Scripts\samlocal.bat" build && "C:\Users\sergi\AppData\Roaming\Python\Python314\Scripts\samlocal.bat" deploy --stack-name resume-backend --no-confirm-changeset --s3-bucket localstack-sam-staging-bucket
	@echo "All Infrastructure deployed successfully."

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
