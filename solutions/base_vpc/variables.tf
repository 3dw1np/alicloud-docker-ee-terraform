variable "name" {
  description = "Solution Name"
}

variable "cidr" {
  description = "CIDR range to use for the VPC"
}

variable "az_count" {
  description = "Number of availability zones to use"
  default = 2
}