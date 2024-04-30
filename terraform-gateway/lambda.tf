resource "aws_lambda_function" "weather" {
  function_name = "${var.prefix}-weather"

  filename = "../lambda-demo/weather.zip"
  source_code_hash = filebase64sha256("../lambda-demo/weather.zip")

  handler = "main.handler"
  runtime = "nodejs20.x"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.prefix}-weather-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.weather.execution_arn}/*/*/*"
}