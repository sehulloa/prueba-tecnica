provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_lambda_function" "lambda_create_employee" {
  function_name = "lambda_create_employee"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  timeout       = 10
  role          = aws_iam_role.lambda_role.arn
  // Especifica la ruta al archivo ZIP de tu función Lambda
  filename = "./sources/lambda-create.zip"
}

resource "aws_lambda_function" "lambda_get_all_employees" {
  function_name = "lambda_get_all_employees"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  timeout       = 10
  role          = aws_iam_role.lambda_role.arn
  // Especifica la ruta al archivo ZIP de tu función Lambda
  filename = "./sources/lambda-getall.zip"
}

resource "aws_lambda_function" "lambda_modify_employee" {
  function_name = "lambda_modify_employee"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  timeout       = 10
  role          = aws_iam_role.lambda_role.arn
  // Especifica la ruta al archivo ZIP de tu función Lambda
  filename = "./sources/lambda-modify.zip"
}

resource "aws_lambda_function" "lambda_delete_employee" {
  function_name = "lambda_delete_employee"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  timeout       = 10
  role          = aws_iam_role.lambda_role.arn
  // Especifica la ruta al archivo ZIP de tu función Lambda
  filename = "./sources/lambda-delete.zip"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "mysql_policy" {
  name        = "mysql-policy"
  description = "Allows Lambda to execute MySQL commands"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "rds-data:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.mysql_policy.arn
}

// API GATEWAY
resource "aws_api_gateway_rest_api" "employee_api" {
  name        = "employee-api"
  description = "Example API Gateway"
}

resource "aws_api_gateway_resource" "employee_resource" {
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
  parent_id   = aws_api_gateway_rest_api.employee_api.root_resource_id
  path_part   = "employee"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.employee_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.employee_api.id
  resource_id             = aws_api_gateway_resource.employee_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.lambda_create_employee.invoke_arn}/employee"
  credentials             = aws_iam_role.lambda_role.arn
}

resource "aws_api_gateway_method" "put_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.employee_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.employee_api.id
  resource_id             = aws_api_gateway_resource.employee_resource.id
  http_method             = aws_api_gateway_method.put_method.http_method
  integration_http_method = "PUT"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.lambda_modify_employee.invoke_arn}/employee"
  credentials             = aws_iam_role.lambda_role.arn
}

resource "aws_api_gateway_method" "delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.employee_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.employee_api.id
  resource_id             = aws_api_gateway_resource.employee_resource.id
  http_method             = aws_api_gateway_method.delete_method.http_method
  integration_http_method = "DELETE"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.lambda_delete_employee.invoke_arn}/employee"
  credentials             = aws_iam_role.lambda_role.arn
}

resource "aws_api_gateway_resource" "all_resource" {
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
  parent_id   = aws_api_gateway_resource.employee_resource.id
  path_part   = "all"
}

resource "aws_api_gateway_method" "get_all_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.all_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_all_integration" {
  rest_api_id             = aws_api_gateway_rest_api.employee_api.id
  resource_id             = aws_api_gateway_resource.all_resource.id
  http_method             = aws_api_gateway_method.get_all_method.http_method
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.lambda_get_all_employees.invoke_arn}/employee/all"
  credentials             = aws_iam_role.lambda_role.arn
}

resource "aws_api_gateway_deployment" "employee_deployment" {
  depends_on  = [aws_api_gateway_integration.post_integration, aws_api_gateway_integration.put_integration, aws_api_gateway_integration.delete_integration, aws_api_gateway_integration.get_all_integration]
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
}

resource "aws_api_gateway_stage" "test_stage" {
  stage_name    = "test"
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  deployment_id = aws_api_gateway_deployment.employee_deployment.id
}
