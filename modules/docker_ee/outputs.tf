output "slb_web_public_ip" {
  value = "${alicloud_slb.web.address}"
}

output "bastion_host_public_ip " {
  value = "${alicloud_instance.bastion.public_ip }"
}