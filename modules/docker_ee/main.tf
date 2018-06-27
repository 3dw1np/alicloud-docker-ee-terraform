### Security Groups and rules
resource "alicloud_security_group" "web" {
  name   = "${var.name}_web_sg"
  vpc_id = "${var.vpc_id}"
}

resource "alicloud_security_group" "docker" {
  name   = "${var.name}_docker_sg"
  vpc_id = "${var.vpc_id}"
}

resource "alicloud_security_group" "ssh" {
  name   = "${var.name}_ssh_sg"
  vpc_id = "${var.vpc_id}"
}

resource "alicloud_security_group_rule" "allow_http_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_https_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_docker_swarm_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "2376/2376"
  priority          = 1
  security_group_id = "${alicloud_security_group.docker.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_docker_port_range_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "12376/12387"
  priority          = 1
  security_group_id = "${alicloud_security_group.docker.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_docker_network_udp_access" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "4789/4789"
  priority          = 1
  security_group_id = "${alicloud_security_group.docker.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_docker_network_tcp_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "7946/7946"
  priority          = 1
  security_group_id = "${alicloud_security_group.docker.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_ssh_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.ssh.id}"
  cidr_ip           = "0.0.0.0/0"
}

### Docker UCP
resource "alicloud_instance" "docker_ucp" {
  instance_name              = "${var.name}_srv"
  instance_type              = "ecs.sn1ne.2xlarge"
  system_disk_category       = "cloud_ssd"
  system_disk_size           = 40
  image_id                   = "${var.image_id}"

  vswitch_id                 = "${element(var.vswitchs_ids, 0)}"
  internet_max_bandwidth_out = 1

  security_groups            = ["${alicloud_security_group.web.id}", "${alicloud_security_group.ssh.id}"]
  user_data                  = "${data.template_cloudinit_config.docker_ucp.rendered}"
  password                   = "${var.ssh_password}"
}

# resource "alicloud_eip" "docker_ucp" {
#   bandwidth            = "5"
#   internet_charge_type = "PayByBandwidth"
# }

# resource "alicloud_eip_association" "docker_ucp" {
#   allocation_id = "${alicloud_eip.docker_ucp.id}"
#   instance_id   = "${alicloud_instance.docker_ucp.id}"
# }

data "template_file" "install_docker_ee" {
  template = "${file("${path.module}/tpl/install_docker_ee.sh")}"

  vars {
    DOCKER_EE_URL = "${var.docker_ee_url}"
  }
}

data "template_file" "install_docker_ucp" {
  template = "${file("${path.module}/tpl/install_docker_ucp.sh")}"
}

data "template_cloudinit_config" "docker_ucp" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.install_docker_ee.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.install_docker_ucp.rendered}"
  }

}