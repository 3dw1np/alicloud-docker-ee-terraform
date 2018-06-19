provider "alicloud" {}

module "vpc" {
  source   = "../../modules/vpc"
  name     = "${var.name}"
  cidr     = "${var.cidr}"
  az_count = "${var.az_count}"
}