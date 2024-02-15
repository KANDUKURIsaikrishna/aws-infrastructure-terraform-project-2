# aws-infrastructure-terraform-project-2
Creating infrastructure in AWS using Terraform (VPC with public and private subnet in production)
# AWS Infrastructure with Terraform



![vpc-example-private-subnets](https://github.com/KANDUKURIsaikrishna/aws-infrastructure-terraform-project-2/assets/50510272/e7a70360-e4d4-449c-8598-c54258a5b179)

## Overview
This Terraform configuration creates an AWS infrastructure with the following components:

The infrastructure includes a Virtual Private Cloud (VPC) with public and private subnets spread across two Availability Zones. Instances run in the private subnets, managed by an Auto Scaling Group and accessed through a load balancer deployed in the public subnets. NAT Gateways provide internet access for instances in private subnets, and a Gateway VPC Endpoint enables access to Amazon S3 without internet access.

## Steps

1. **VPC (Virtual Private Cloud):**
   - Define a VPC with a specified CIDR block.

2. **Subnets:**
   - Create public and private subnets across two Availability Zones.
   - Ensure each subnet is associated with the VPC and has unique CIDR blocks.

3. **NAT Gateways:**
   - Set up NAT Gateways in each public subnet for instances in private subnets to access the internet.

4. **Load Balancer:**
   - Configure an Application Load Balancer across public subnets to distribute traffic to instances in private subnets.

5. **Auto Scaling Group:**
   - Create an Auto Scaling Group to manage the number of instances.
   - Launch instances in private subnets and configure minimum, maximum, and desired capacities.

6. **Security Groups:**
   - Define security groups for load balancer, instances, etc., to control inbound and outbound traffic.

7. **Launch Configuration:**
   - Specify launch specifications for instances, including AMI ID, instance type, security groups, etc.

8. **Gateway VPC Endpoint for S3:**
   - Create a VPC endpoint to allow instances in private subnets to access Amazon S3 without internet access.

9. **Route Tables:**
   - Create route tables for public and private subnets.
   - Ensure public subnets have routes to the internet gateway or NAT gateway.
   - Associate private subnets with the appropriate route tables.

10. **IAM Roles and Policies (optional):**
    - Define IAM roles and policies to grant necessary permissions to instances and services.

## Usage

1. Clone this repository.
2. Ensure you have Terraform installed locally.
3. Update the `variables.tf` file with your specific configurations (e.g., AMI ID, VPC CIDR blocks).
4. Run `terraform init` to initialize the working directory.
5. Run `terraform plan` to see the execution plan.
6. If the plan looks good, apply changes using `terraform apply`.
7. After applying changes, verify the AWS resources in the AWS Management Console.

Make sure to handle Terraform state management properly, especially in a collaborative environment.

