# Weather Docker Demo

This is a simple application to serve as an example C# application to be used with ECS.

## Getting started

You can build a Docker image of the application by running the following command:

```shell
docker build -t <ecrRepo>:latest .
```

`<ecrRepo>` should be replaced with the output from the `terraform-ecs-dotnet` folder. 

You can then login to the ECR repository by running 

```shell
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
```

(replacing the region and account number with your values again)

And then running 

```shell
docker push <ecrRepo>:latest
```