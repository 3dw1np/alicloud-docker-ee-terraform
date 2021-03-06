Github repo: [https://github.com/3dw1np/alicloud-docker-ee-terraform](https://github.com/3dw1np/https://github.com/3dw1np/alicloud-docker-ee-terraform)

# Deploy Docker EE (+ UCP / DTR) on Alibaba Cloud with Terraform

At Alibaba Cloud, we use Terraform to provide fast demos to our customers.
I truly believe that the infrasture-as-code is the quick way to leverage a public cloud provider services. Instead of clicking on the Web Console UI, the logic of the infrasture-as-code allows us to define more accuratly each used services, automate the entire infrastructure and version it with a versionning control (git).

## High-level design
![HLD](https://raw.githubusercontent.com/3dw1np/alicloud-docker-ee-terraform/master/HLD.png)

## Export environment variables
We provide the Alicloud credentials with envrionments variables. In this tutorial, we are going to use the Singapore Region (ap-southeast-1).
 
```
root@alicloud:~$ export ALICLOUD_ACCESS_KEY="anaccesskey"
root@alicloud:~$ export ALICLOUD_SECRET_KEY="asecretkey"
root@alicloud:~$ export ALICLOUD_REGION="ap-southeast-1"
```

If you don't have an access key for your Alicloud account yet, just follow this [tutorial](https://www.alibabacloud.com/help/doc-detail/28955.htm).

## Install Terraform
To install Terraform, download the appropriate package for your OS. The download contains an executable file that you can add in your global PATH.

Verify your PATH configuration by typing the terraform

```
root@alicloud:~$ terraform
Usage: terraform [--version] [--help] <command> [args]
```

## Setup Alicloud terraform provider (> v1.9.4)
The official repository for Alicloud terraform provider is [https://github.com/alibaba/terraform-provider]() 

* Download a compiled binary from https://github.com/alibaba/terraform-provider/releases.
* Create a custom plugin directory named **terraform.d/plugins/darwin_amd64**.
* Move the binary inside this custom plugin directory.
* Create **test.tf** file for the plan and provide inside:

```
# Configure the Alicloud Provider
provider "alicloud" {}
```

* Initialize the working directory but Terraform will not download the alicloud provider plugin from internet, because we provide a newest version locally.

```
terraform init
```

## Deployment steps
### Base vpc
```bash
terraform init solutions/base_vpc
terraform plan|apply|destroy \
  -var-file=parameters/base_vpc.tfvars \
  -state=states/base_vpc.tfstate \
  solutions/base_vpc
```

### Get Docker Enterprise Edition for Ubuntu Trial Url
Please follow the prerequisites to get your trial access of Docker EE :
[https://docs.docker.com/install/linux/docker-ee/ubuntu/]()

### Docker EE with UCP (Universal Control Plane) and DTR (Docker Trusted Registry)
```bash
terraform init solutions/docker_ha
terraform plan|apply|destroy \
  -var 'ssh_password=<SSH_PASSWORD>' \
  -var 'docker_ee_url=<DOCKER_EE_URL>' \
  -var-file=parameters/docker_ha.tfvars \
  -state=states/docker_ha.tfstate \
  solutions/docker_ha
```

### Add worker nodes
Default login: admin / admindocker
To finalise the setup of the cluster by adding the worker nodes, you need to login into the UCP web ui and follow:
[https://docs.docker.com/ee/ucp/admin/install/#step-7-join-worker-nodes]()


### Setup SSL
https://docs.docker.com/datacenter/dtr/2.0/configure/config-security/#install-registry-certificates-on-client-docker-daemons
```bash
export DOMAIN_NAME=dtr.yourdomain.com
openssl s_client -connect $DOMAIN_NAME:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM | sudo tee /usr/local/share/ca-certificates/$DOMAIN_NAME.crt
sudo update-ca-certificates
``

### Setup Docker Trusted Registry (DTR) on a worker node
Choose one node worker already added to the cluster and then follow:
[https://docs.docker.com/ee/dtr/admin/install/]()

You can set the option "“Disabled TLS verification For UCP" on installing DTR to avoid issue with the UDP certificate.

## Issues