# Terraform ECS Example

The Terraform files in this folder are intended to be used with the C# application inside the `docker-demo` folder and will provision the required resources inside your AWS account.

## Getting started

Update the lines commented on inside the `main.tf` file. You should specify the name of your bucket and the AWS account number. You may also choose a new S3 bucket key.

Once that is done, you can run `tofu init` inside this folder. Afterwards you may run `tofu plan -out resulting-plan` to then finally apply the files against your account by running `tofu apply "resulting-plan"`. It should then provision all the required resources.