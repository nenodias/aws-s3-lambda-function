provider "aws" {
  region     = "us-east-1"
}

// Criando um bucket
resource "aws_s3_bucket" "nenodias_bucket" {
  bucket = "nenodias-s3-lambda"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Managedby   = "Terraform"
  }
}

// Criando um role para a função lambda
resource "aws_iam_role" "nenodias_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

// Criando um arquivo zip com o código da função lambda
data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/src/lambda.py"
  output_path = "lambda_function_payload.zip"
}

// Criando a função lambda
resource "aws_lambda_function" "nenodias_s3_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "nenodias-s3-lambda"
  role          = aws_iam_role.nenodias_role.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

// Permissão para o lambda acessar o bucket
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nenodias_s3_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.nenodias_bucket.arn
}

// Criando uma notificação do bucket para o lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.nenodias_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.nenodias_s3_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

// Criando um grupo de logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/nenodias-s3-lambda"
  retention_in_days = 1
}

// Criando uma política para acessar o CloudWatch
resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

// Anexando a política ao role
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = aws_iam_role.nenodias_role.name
}

// Criando uma política para acessar o bucket
resource "aws_iam_policy" "s3_access" {
  name = "s3_access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = aws_s3_bucket.nenodias_bucket.arn
      }
    ]
  })
}

// Anexando a política ao role
resource "aws_iam_role_policy_attachment" "lambda_s3" {
  policy_arn = aws_iam_policy.s3_access.arn
  role       = aws_iam_role.nenodias_role.name
}
