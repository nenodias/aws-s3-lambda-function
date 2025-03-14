import os
import logging
import boto3
import botocore

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
   logger.info('Lambda function invoked')
   logger.info('## ENVIRONMENT VARIABLES')
   logger.info(os.environ["AWS_LAMBDA_LOG_GROUP_NAME"])
   logger.info(os.environ["AWS_LAMBDA_LOG_STREAM_NAME"])
   logger.info(os.environ["AWS_LAMBDA_FUNCTION_NAME"])
   logger.info(os.environ["AWS_LAMBDA_FUNCTION_MEMORY_SIZE"])
   logger.info(os.environ["AWS_LAMBDA_FUNCTION_VERSION"])
   logger.info(os.environ["AWS_REGION"])
   logger.info(f'boto3 version: {boto3.__version__}')
   logger.info(f'botocore version: {botocore.__version__}')
   logger.info('## EVENT')
   logger.info(f'event: {event}')
   logger.info(f'context: {context}')
