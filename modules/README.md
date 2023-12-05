This repository contains Terraform scripts to deploy a basic AWS infrastructure with an Application Load Balancer (ALB) and web servers.

Prerequisites
Clone the Repository: Clone this repository to your local machine.

git clone <repository-url>

S3 Module Setup: Navigate to the s3 directory and run the Terraform commands to set up the S3 bucket for storing Terraform state.

cd s3
terraform init
terraform apply

Network Module Setup: Go to the network directory and run Terraform commands to create the network infrastructure.

cd ../network
terraform init
terraform apply

Web Server Setup: Move to the webserver directory and create an SSH key pair.

cd ../webserver
ssh-keygen -t rsa -f <key-name>
Then, run Terraform to deploy the web servers.

terraform init
terraform apply

ALB Module Setup: Move to the alb directory and run Terraform to deploy the Application Load Balancer.

cd ../alb
terraform init
terraform apply

Deployment

Ensure you have completed the prerequisites.
Follow the steps above to run Terraform in each module: s3, network, webserver, and alb.
After deploying the ALB, copy the DNS link provided.

Cleanup
To clean up and destroy the deployed infrastructure, run the following commands in reverse order:

cd alb
terraform destroy

cd ../webserver
terraform destroy

# Repeat for network and s3 modules

Note
This README provides a basic guide for deploying and cleaning up the infrastructure. Ensure you have the necessary AWS credentials and Terraform installed on your machine.