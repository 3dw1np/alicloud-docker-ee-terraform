

resource "alicloud_security_group" "web" {
  name   = "${var.name}_web_sg"
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

resource "alicloud_slb" "web" {
  name                 = "${var.name}_web_slb"
  internet             = true
  internet_charge_type = "paybytraffic"
}

resource "alicloud_slb_listener" "http" {
  load_balancer_id          = "${alicloud_slb.web.id}"
  backend_port              = 80
  frontend_port             = 80
  bandwidth                 = 10
  protocol                  = "http"
  health_check_connect_port = 80
  health_check_http_code    = "http_2xx,http_3xx"
  sticky_session            = "on"
  sticky_session_type       = "insert"
  cookie                    = "alicloud_${var.name}"
  cookie_timeout            = 86400
}

resource "alicloud_slb_attachment" "default" {
  load_balancer_id = "${alicloud_slb.web.id}"
  instance_ids     = ["${alicloud_instance.docker.*.id}"]
}

resource "alicloud_instance" "bastion" {
  instance_name              = "${var.name}_bastion_srv"
  instance_type              = "ecs.n4.large"
  system_disk_category       = "cloud_ssd"
  system_disk_size           = 50
  image_id                   = "${var.image_id}"

  vswitch_id                 = "${element(var.vswitchs_ids, 0)}"
  internet_max_bandwidth_out = 1

  security_groups            = ["${alicloud_security_group.ssh.id}"]
  //TODO: remove this
  password                   = "${var.ssh_password}"
}

resource "alicloud_instance" "docker" {
  instance_name              = "${var.name}_srv_${count.index}"
  instance_type              = "ecs.sn1ne.2xlarge"
  system_disk_category       = "cloud_ssd"
  system_disk_size           = 50
  image_id                   = "${var.image_id}"
  count                      = 4

  vswitch_id                 = "${element(var.vswitchs_ids, count.index)}"
  internet_max_bandwidth_out = 1 // O to not allocate public IP for docker instances

  security_groups            = ["${alicloud_security_group.web.id}", "${alicloud_security_group.ssh.id}"]
  user_data                  = "${data.template_file.user_data.rendered}"
  //TODO: remove this
  password                   = "${var.ssh_password}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/tpl/user_data.sh")}"

  # vars {
  #   WEB_URL         = "http://${alicloud_slb.web.address}"
  # }
}