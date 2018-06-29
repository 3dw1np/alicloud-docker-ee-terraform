# output "docker_ucp_eip" {
#   value = "${alicloud_eip.docker_ucp.ip_address}"
# }

output "slb_web_swarm_public_ip" {
  value = "${alicloud_slb.web_swarm.address}"
}

output "slb_web_k8s_public_ip" {
  value = "${alicloud_slb.web_k8s.address}"
}