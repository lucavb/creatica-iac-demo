resource "aws_api_gateway_rest_api" "weather" {
  name        = "${var.prefix}-weather-api"
  description = "Weather API for demo purposes"
}

resource "aws_api_gateway_resource" "weather" {
  rest_api_id = aws_api_gateway_rest_api.weather.id
  parent_id   = aws_api_gateway_rest_api.weather.root_resource_id
  path_part   = "weather"
}

resource "aws_api_gateway_method" "weather" {
  rest_api_id   = aws_api_gateway_rest_api.weather.id
  resource_id   = aws_api_gateway_resource.weather.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "weather" {
  rest_api_id             = aws_api_gateway_rest_api.weather.id
  resource_id             = aws_api_gateway_resource.weather.id
  http_method             = aws_api_gateway_method.weather.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.weather.invoke_arn
}

resource "aws_api_gateway_method_response" "weather" {
  rest_api_id = aws_api_gateway_rest_api.weather.id
  resource_id = aws_api_gateway_resource.weather.id
  http_method = aws_api_gateway_method.weather.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "weather" {
  rest_api_id = aws_api_gateway_rest_api.weather.id
  resource_id = aws_api_gateway_resource.weather.id
  http_method = aws_api_gateway_method.weather.http_method
  status_code = aws_api_gateway_method_response.weather.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "weather" {
  depends_on = [aws_api_gateway_integration.weather]
  rest_api_id = aws_api_gateway_rest_api.weather.id
  stage_name  = "prod"
}
