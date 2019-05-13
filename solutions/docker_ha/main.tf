provider "alicloud" {
	region	= "eu-central-1"
}

module "docker_ee" {
  source       = "../../modules/docker_ee"
  name         = "${var.name}"
  vpc_id       = "${var.vpc_id}"
  vswitchs_ids = "${var.vswitchs_ids}"
  image_id     = "${var.image_id}"
  ssh_password = "${var.ssh_password}"
  docker_ee_url = "${var.docker_ee_url}"
}