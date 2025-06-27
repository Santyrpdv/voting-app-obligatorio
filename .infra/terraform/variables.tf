variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "demo-vpc"
}


variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "The availability zones for the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "demo-eks"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
 default     = "demo-node-group"
}

variable "existing_role_arn" {
  description = "ARN de IAM "
  type        = string
}