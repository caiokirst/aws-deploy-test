variable "aws_region" {
  description = "AWS Region for deployment"
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  description = "CIDR Block for the VPC"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 Instance Type required for Wazuh"
  default     = "t3.xlarge"
}