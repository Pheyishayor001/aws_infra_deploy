variable "region" {
  description = "region"
  type        = string
  default     = "us-east-1"

}

variable "AZs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "CIDR_block" {
  type        = list(string)
  description = "CIDR block"
  default     = ["10.0.0.0/16"]
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

# key pair - Location to the SSH Key generate using openssl or ssh-keygen or AWS KeyPair
variable "ssh_file" {
  description = "Path to an SSH public key"
  default     = "~/Downloads/network.pem"
}

variable "AMI" {
  description = "AMI"
  default     = "ami-063d43db0594b521b"
}

variable "root_volume_size" {
  type    = number
  default = 8 #GB
}
variable "myEbs_Volume" {
  type    = number
  default = 1 #GB
}