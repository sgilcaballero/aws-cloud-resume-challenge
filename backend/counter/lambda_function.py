import json
import os
import boto3
from botocore.exceptions import ClientError

# Read the local endpoint fallback provided by the LocalStack runtime network
LOCALSTACK_HOSTNAME = os.environ.get("LOCALSTACK_HOSTNAME")
REGION = os.environ.get("AWS_REGION", "us-east-1")

if LOCALSTACK_HOSTNAME:
    # Point internal SDK requests directly back to the LocalStack gateway container
    dynamodb = boto3.resource(
        "dynamodb",
        region_name=REGION,
        endpoint_url=f"http://{LOCALSTACK_HOSTNAME}:4566"
    )
else:
    dynamodb = boto3.resource("dynamodb", region_name=REGION)

TABLE_NAME = "cloud-resume-challenge-counter"
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        # Atomic increment update pattern for DynamoDB core attributes
        response = table.update_item(
            Key={"id": "count_record"},
            UpdateExpression="ADD view_count :inc",
            ExpressionAttributeValues={":inc": 1},
            ReturnValues="UPDATED_NEW"
        )
        
        current_count = int(response["Attributes"]["view_count"])
        
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*", # Required for CORS matching in Phase 4
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST,GET,OPTIONS"
            },
            "body": json.dumps({"count": current_count})
        }
        
    except ClientError as e:
        print(f"Database Exception: {e.response['Error']['Message']}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to update internal view record counter"})
        }
