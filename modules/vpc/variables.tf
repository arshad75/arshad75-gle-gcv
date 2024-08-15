variable "region" {
  description = "AWS region to deploy the infrastructure"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR range for the VPC. Default is a /16 network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
 description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Default tags to apply to resources"
  type        = map(string)
  default     = {}
}