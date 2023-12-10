Infrastructure Deployment with Terraform and Ansible
Overview
This project automates the deployment of a static website on AWS infrastructure using Terraform for infrastructure provisioning and Ansible for configuration management. The deployment includes the creation of an S3 bucket for storing Terraform state, network setup, EC2 instances for a web server, and the installation of a static website.

Prerequisites
S3 Bucket Creation:

Create a public S3 bucket named production-image-<your name>.
Uncheck the option for "Block all public access" during bucket creation.
Accept the acknowledgment.
Bucket Policy:

Add a policy to allow GetObject from the bucket.
Deployment Steps
Terraform Setup
Navigate to the terraform folder.

Run the following commands:

bash
Copy code
terraform init
terraform validate
terraform plan
terraform apply
Enter your name when prompted.

After deployment, update the bucket name in the network configuration file and then in the webserver configuration and main files.

Deploy the webserver module first, followed by the network module.

SSH Key Generation
Generate the SSH key named Impressive-production in the webserver module.

Deploy the webserver module.

Retrieve the website URL from the webserver module's output. This URL corresponds to the load balancer's DNS.

Ansible Setup
Navigate to the ansible folder.

Install Ansible and boto3 using the following commands:

bash
Copy code
python3 -m pip install --user ansible
pip install boto3
Copy the SSH key generated in the webserver module to the ansible folder.

Run the Ansible playbook:

bash
Copy code
ansible-playbook -i aws_ec2.yml playbook.yml
View the Deployed Website
Once Ansible is deployed, go to the web browser.

Paste the load balancer's DNS link.

You should now see the static website deployed using Terraform and Ansible.

Clean Up
Ensure to clean up resources to avoid unnecessary costs:

Webserver:

Navigate to the terraform/webserver folder.
Run terraform destroy.
Network:

Navigate to the terraform/network folder.
Run terraform destroy.
S3 Bucket:

Navigate to the terraform/s3 folder.
Run terraform destroy.
Manually remove any remaining resources, such as the S3 bucket and associated objects.

This README provides a comprehensive guide for setting up, deploying, and cleaning up the infrastructure and serves as a reference for users and contributors.