**Terraform Project Documentation**

**Overview**

This Terraform configuration sets up a scalable infrastructure on AWS, including a Virtual Private Cloud (VPC) with both public and private subnets, NAT gateways, EC2 instances, and security groups. The infrastructure is designed to provide a secure, high-availability environment suitable for deploying applications.

**Resources Provisioned**

1. **VPC**: Creates a Virtual Private Cloud with a /16 CIDR block, serving as the isolated network for your resources.
2. **Subnets**:
    - **Public Subnets**: Multiple subnets across different availability zones, each with internet access via an Internet Gateway.
    - **Private Subnets**: Multiple subnets designed for internal resources, using a NAT Gateway for outbound internet access.
3. **Internet Gateway (IGW)**: Enables internet connectivity for resources in public subnets.
4. **NAT Gateway**: Provides internet access for resources in private subnets while keeping them isolated.
5. **Route Tables**:
    - **Public Route Table**: Directs traffic from public subnets to the Internet Gateway.
    - **Private Route Table**: Directs traffic from private subnets to the NAT Gateway.
6. **Elastic IPs**: Allocates Elastic IPs for NAT Gateways to ensure a static, reachable IP address.
7. **Security Groups**:
    - **Public Instance Security Group**: Allows HTTP and SSH traffic from any IP.
    - **Private Instance Security Group**: Restricts SSH access to internal traffic from the VPC.
8. **EC2 Instances**:
    - **Public Instances**: Accessible from the internet, associated with public subnets.
    - **Private Instances**: Isolated from the internet, associated with private subnets.
9. **EBS Volumes**: Additional storage attached to both public and private EC2 instances.

**Inputs**

- region: AWS region for deploying resources.
- public_subnet_cidrs: CIDR blocks for public subnets.
- private_subnet_cidrs: CIDR blocks for private subnets.
- AZs: List of availability zones for subnet distribution.
- AMI: Amazon Machine Image ID for EC2 instances.
- root_volume_size: Size of the root EBS volume.
- myEbs_Volume: Size of additional EBS volumes.

**Outputs**

- **VPC ID**: The ID of the created VPC.
- **Internet Gateway ID**: The ID of the Internet Gateway.
- **Public & Private Route Tables**: IDs of the route tables for public and private subnets.
- **Subnets**: IDs of the public and private subnets.
- **Elastic IPs**: IDs of the allocated Elastic IP addresses.
- **NAT Gateway IDs**: IDs of the created NAT Gateways.
- **Public EC2 Instance IPs**: Public IP addresses of the deployed instances.

**Usage**

1. **Clone the Repository**: Ensure you have Terraform installed.
2. **Initialize Terraform**:

terraform init

1. **Validate Configuration**:

terraform validate

1. **Apply Changes**:

terraform apply

1. **View Outputs**: After deployment, check the listed outputs for resource details.

**Notes**

- The infrastructure supports scalability by utilizing count and dynamic indexing for resources like subnets, route tables, and EC2 instances.
- Security groups are defined to limit access to critical ports and allow internal communication within the VPC.
- Ensure that the provided AWS credentials have sufficient permissions to create the specified resources.

This setup is ideal for environments requiring a mix of public-facing and internally isolated resources, ensuring secure access and scalability.
