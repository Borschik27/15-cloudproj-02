# VM Platform
default_image_family    = "ubuntu-24-04-lts"
default_platform_id     = "standard-v3"
default_zone            = "ru-central1-a"

# Default vm user
default_vm_user = "ubuntu"

# Cloud init
### Find packages in distro this pack-list on 24.04 tls
pack_list           = ["libsoup-2.4-1","libsoup2.4-common","libsoup2.4-dev","libappstream5","python3","python3-pip","curl","net-tools","ca-certificates","apt-transport-https","ssh"]

sudo_cloud_init     = "ALL=(ALL) NOPASSWD:ALL"

sudo_vm_u_group     = "sudo"
default_vm_u_shell  = "/bin/bash"

### VPC/Subnet
vpc_name        = "cloud_testing"
subnet_name1    = "public"
subnet_name2    = "private"

public_cidr     = ["192.168.10.0/24"]
private_cidr    = ["192.168.20.0/24"]

### Security group
sg_nat_name     = "nat-instance-sg"

### Goute table
route_table_name  = "nat-instance-route"

### LEMP variables
lemp_name_group     = "lemp-group"
lemp_cores          = "2"
lemp_memory         = "2"
lemp_hdd_size       = "20"
lemp_hdd_type       = "network-hdd"
lemp_core_fraction  = "50"
lemp_image_id       = "fd827b91d99psvq5fjit"

### Bucket
image_path = "./files/1.JPG"
bucket_name = "web-sypchik"