variable "name" {
  description = "Solution Name"
}

variable "vpc_id" {
  description = "Id of the VPC where to deploy the resources"
}

variable "vswitchs_ids" {
  type = "list"
  description = "Ids of the vswitchs"
}

variable "image_id" {
  description = "Image id used for nodes"
}

variable "ssh_password" {
  description = "Ssh password for the hosts"
}

variable "docker_ee_url" {
  description = "Url of Docker Enterprise Edition for Ubuntu"
}