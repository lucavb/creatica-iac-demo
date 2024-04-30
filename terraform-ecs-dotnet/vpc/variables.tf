variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.200.0.0/20"
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones in which to create subnets."
  type        = list(string)
}


variable "name" {
  description = "The name of the vpc"
  type        = string
}