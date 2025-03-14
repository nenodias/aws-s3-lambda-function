import os
import logging
import boto3
import botocore

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
   logging.info('Lambda function invoked')
   logging.info('## ENVIRONMENT VARIABLES')
   logging.info(os.environ["AWS_LAMBDA_LOG_GROUP_NAME"])
   logging.info(os.environ["AWS_LAMBDA_LOG_STREAM_NAME"])
   logging.info(os.environ["AWS_LAMBDA_FUNCTION_NAME"])
   logging.info(os.environ["AWS_LAMBDA_FUNCTION_MEMORY_SIZE"])
   logging.info(os.environ["AWS_LAMBDA_FUNCTION_VERSION"])
   logging.info(os.environ["AWS_REGION"])
   logger.info(f'boto3 version: {boto3.__version__}')
   logger.info(f'botocore version: {botocore.__version__}')
   logging.info('## EVENT')
   logger.info(f'event: {event}')
   logger.info(f'context: {context}')
