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

resource "alicloud_security_group_rule" "allow_http_swarm_hc_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8000/8000"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "100.64.0.0/10" # IP address range for healthcheck
}

resource "alicloud_security_group_rule" "allow_http_swarm_k8s_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "34080/34080"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "100.64.0.0/10" # IP address range for healthcheck
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

resource "alicloud_security_group_rule" "allow_https_swarm_hc_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8443/8443"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "100.64.0.0/10" # IP address range for healthcheck
}

resource "alicloud_security_group_rule" "allow_https_swarm_k8s_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "34443/34443"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "100.64.0.0/10" # IP address range for healthcheck
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

resource "alicloud_security_group_rule" "allow_docker_network_kubectl_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "6443/6443"
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

### Docker manager UCP
resource "alicloud_instance" "docker_ucp_manager" {
  host_name                  = "manager"
  instance_name              = "${var.name}_manager_srv"
  instance_type              = "ecs.sn1ne.2xlarge"
  system_disk_category       = "cloud_ssd"
  system_disk_size           = 40
  image_id                   = "${var.image_id}"

  vswitch_id                 = "${element(var.vswitchs_ids, 0)}"
  internet_max_bandwidth_out = 1

  security_groups            = ["${alicloud_security_group.docker.id}", "${alicloud_security_group.web.id}", "${alicloud_security_group.ssh.id}"]
  user_data                  = "${data.template_cloudinit_config.docker_ucp_manager.rendered}"
  password                   = "${var.ssh_password}"
}

# resource "alicloud_eip" "docker_ucp_manager" {
#   bandwidth            = "5"
#   internet_charge_type = "PayByBandwidth"
# }

# resource "alicloud_eip_association" "docker_ucp_manager" {
#   allocation_id = "${alicloud_eip.docker_ucp_manager.id}"
#   instance_id   = "${alicloud_instance.docker_ucp_manager.id}"
# }

### Docker worker (need manual setup UCP and only one DTR)
resource "alicloud_instance" "docker_wkr" {
  host_name                  = "worker${count.index}"
  instance_name              = "${var.name}_worker_${count.index}_srv"
  instance_type              = "ecs.sn1ne.2xlarge"
  system_disk_category       = "cloud_ssd"
  system_disk_size           = 40
  image_id                   = "${var.image_id}"
  count                      = 3

  vswitch_id                 = "${element(var.vswitchs_ids, count.index)}"
  internet_max_bandwidth_out = 1

  security_groups            = ["${alicloud_security_group.docker.id}", "${alicloud_security_group.web.id}", "${alicloud_security_group.ssh.id}"]
  user_data                  = "${data.template_cloudinit_config.docker_ucp_worker.rendered}"
  password                   = "${var.ssh_password}"
}

# resource "alicloud_eip" "docker_wkr" {
#   bandwidth            = "5"
#   internet_charge_type = "PayByBandwidth"
# }

# resource "alicloud_eip_association" "docker_wkr" {
#   allocation_id = "${alicloud_eip.docker_wkr.id}"
#   instance_id   = "${alicloud_instance.docker_wkr.id}"
# }

### Public Load Balancer for Swarm
resource "alicloud_slb" "web_swarm" {
  name                 = "${var.name}_web_swarm_slb"
  internet             = true
  internet_charge_type = "paybytraffic"
}

resource "alicloud_slb_listener" "http_swarm" {
  load_balancer_id          = "${alicloud_slb.web_swarm.id}"
  backend_port              = 8000
  frontend_port             = 80
  bandwidth                 = 10
  protocol                  = "tcp"
  sticky_session            = "on"
  sticky_session_type       = "insert"
  cookie                    = "alicloud_${var.name}_web_swarm"
  cookie_timeout            = 86400
}

resource "alicloud_slb_listener" "https_swarm" {
  load_balancer_id          = "${alicloud_slb.web_swarm.id}"
  backend_port              = 8443
  frontend_port             = 443
  bandwidth                 = 10
  protocol                  = "tcp"
  sticky_session            = "on"
  sticky_session_type       = "insert"
  cookie                    = "alicloud_${var.name}_web_swarm"
  cookie_timeout            = 86400
}

resource "alicloud_slb_attachment" "web_swarm" {
  load_balancer_id = "${alicloud_slb.web_swarm.id}"
  instance_ids     = ["${alicloud_instance.docker_wkr.*.id}"]
}

### Public Load Balancer for K8S
resource "alicloud_slb" "web_k8s" {
  name                 = "${var.name}_web_k8s_slb"
  internet             = true
  internet_charge_type = "paybytraffic"
}

resource "alicloud_slb_listener" "http_k8s" {
  load_balancer_id          = "${alicloud_slb.web_k8s.id}"
  backend_port              = 34080
  frontend_port             = 80
  bandwidth                 = 10
  protocol                  = "tcp"
  sticky_session            = "on"
  sticky_session_type       = "insert"
  cookie                    = "alicloud_${var.name}_web_k8s"
  cookie_timeout            = 86400
}

resource "alicloud_slb_listener" "https_k8s" {
  load_balancer_id          = "${alicloud_slb.web_k8s.id}"
  backend_port              = 34443
  frontend_port             = 443
  bandwidth                 = 10
  protocol                  = "tcp"
  sticky_session            = "on"
  sticky_session_type       = "insert"
  cookie                    = "alicloud_${var.name}_web_k8s"
  cookie_timeout            = 86400
}

resource "alicloud_slb_attachment" "web_k8s" {
  load_balancer_id = "${alicloud_slb.web_k8s.id}"
  instance_ids     = ["${alicloud_instance.docker_wkr.*.id}"]
}

### Template script bash
data "template_file" "install_docker_ee" {
  template = "${file("${path.module}/tpl/install_docker_ee.sh")}"

  vars {
    DOCKER_EE_URL = "${var.docker_ee_url}"
  }
}

data "template_file" "install_docker_ucp" {
  template = "${file("${path.module}/tpl/install_docker_ucp.sh")}"
}

data "template_cloudinit_config" "docker_ucp_manager" {
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

data "template_cloudinit_config" "docker_ucp_worker" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.install_docker_ee.rendered}"
  }
}