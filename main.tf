# Create bucket
resource "yandex_storage_bucket" "bucket" {
  bucket     = var.bucket_name
  acl        = "public-read"

  default_storage_class = "COLD"
  folder_id = var.folder_id

  anonymous_access_flags {
    read        = true
    list        = true
    config_read = false
  }
}

# Upload file on bucket
resource "yandex_storage_object" "image" {
  bucket     = yandex_storage_bucket.bucket.bucket
  key        = "main.jpg"
  source     = var.image_path
  acl        = "public-read"
}

#######################################################
# Cloud Init Init
### Cloud init for ubunutu 2404
data "template_file" "cloudinit_2404" {
  template = file("${path.module}/templates/cloud-init-2404.yaml.tpl")

  vars = {
    ssh_key          = var.vms_ssh_root_key,
    uname            = var.default_vm_user,
    ugroup           = var.sudo_vm_u_group,
    shell            = var.default_vm_u_shell,
    s_com            = var.sudo_cloud_init,
    pack             = join("\n  - ", var.pack_list),
    vm_user_password = var.default_vm_user_password
  }
}
### End Cloud init for ubunutu 2404

### Cloud init for services
data "template_file" "cloudinit_services" {
  template = file("${path.module}/templates/cloud-init-services.yaml.tpl")

  vars = {
    ssh_key          = var.vms_ssh_root_key,
    uname            = var.default_vm_user,
    ugroup           = var.sudo_vm_u_group,
    shell            = var.default_vm_u_shell,
    s_com            = var.sudo_cloud_init,
    vm_user_password = var.default_vm_user_password
  }
}
### End Cloud init for services

### Cloud init for web service
data "template_file" "cloudinit_web" {
  template = file("${path.module}/templates/cloud-init-web.yaml.tpl")

  vars = {
    ssh_key          = var.vms_ssh_root_key,
    uname            = var.default_vm_user,
    ugroup           = var.sudo_vm_u_group,
    shell            = var.default_vm_u_shell,
    s_com            = var.sudo_cloud_init,
    vm_user_password = var.default_vm_user_password
    bucket_name      = yandex_storage_bucket.bucket.bucket
  }
}
### End Cloud init for web service
# End cloud init

###########################################

# Init Static Public address
resource "yandex_vpc_address" "nat_addr" {
  name = "nat-ip"
  deletion_protection = false
  external_ipv4_address {
    zone_id = var.default_zone
  }
}

resource "yandex_vpc_address" "lb-addr" {
  name = "lb-ip"
  deletion_protection = false
  external_ipv4_address {
    zone_id = var.default_zone
  }
}

############################################

# Init VPC/Subnet
### Create VPC
resource "yandex_vpc_network" "cloud_proj" {
  name = var.vpc_name
}
### End VPC

### Create subnet public
resource "yandex_vpc_subnet" "public" {
  depends_on = [ yandex_vpc_network.cloud_proj ]

  name           = var.subnet_name1
  zone           = var.default_zone
  network_id     = yandex_vpc_network.cloud_proj.id
  v4_cidr_blocks = var.public_cidr
}
### End create subnet public

### Create subnet private
resource "yandex_vpc_subnet" "private" {
  depends_on = [ yandex_vpc_network.cloud_proj ]

  name           = var.subnet_name2
  zone           = var.default_zone
  network_id     = yandex_vpc_network.cloud_proj.id
  v4_cidr_blocks = var.private_cidr
  route_table_id = yandex_vpc_route_table.nat_instance_route.id
}
### End create subnet private
# End Init VPC/Subnet

####################################

# Init VM Cluster
### Create nat instance
resource "yandex_compute_instance" "nat" {
  for_each = var.vms_resources_nat

  depends_on = [ yandex_vpc_subnet.public ]

  name        = each.value.name
  platform_id = var.default_platform_id
  zone        = var.default_zone
  hostname    = each.value.hostname

  metadata = {
    user-data          = data.template_file.cloudinit_services.rendered
    serial-port-enable = 1
  }

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = each.value.services_image_id
      size = each.value.hdd_size
      type = each.value.hdd_type
    }
  }

  network_interface {
    subnet_id   = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat_instance_sg.id]
    nat         = each.value.nat_status
    nat_ip_address = yandex_vpc_address.nat_addr.external_ipv4_address[0].address
    ip_address  = each.value.local_ip
  }
}
### End create nat-instace

#######################################################

## Create route-table/static-route
resource "yandex_vpc_route_table" "nat_instance_route" {
  name       = var.route_table_name
  network_id = yandex_vpc_network.cloud_proj.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat["nat-instance"].network_interface[0].ip_address
  }
}
## End create route-table/static-route

### Create security group
resource "yandex_vpc_security_group" "nat_instance_sg" {
  name       = var.sg_nat_name
  network_id = yandex_vpc_network.cloud_proj.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}
### End create security group 

#######################################################

### Create LEMP groups
resource "yandex_compute_instance_group" "lamp_group" {
  name = "lamp-group"

  depends_on = [ yandex_vpc_security_group.nat_instance_sg, yandex_vpc_route_table.nat_instance_route ]

  folder_id = var.folder_id
  service_account_id = var.services_acc_id
  deletion_protection = "false"
  
  instance_template {
    name = "{instance.tag}"
    platform_id = var.default_platform_id
    resources {
      memory = var.lemp_memory
      cores  = var.lemp_cores
      core_fraction = var.lemp_core_fraction
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.lemp_image_id
        size = var.lemp_hdd_size
        type = var.lemp_hdd_type
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.cloud_proj.id
      subnet_ids         = [yandex_vpc_subnet.private.id]
      security_group_ids = [yandex_vpc_security_group.nat_instance_sg.id]
      ip_address         = "{ip_{instance.tag}}"
    }

    metadata = {
      user-data          = data.template_file.cloudinit_web.rendered
      serial-port-enable = 1
    }
  }

  variables = {
    ip_lemp01 = "192.168.20.101"
    ip_lemp02 = "192.168.20.102"
    ip_lemp03 = "192.168.20.103"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

## Справка `https://yandex.cloud/ru/docs/compute/operations/instance-groups/create-with-fixed-ip`
  allocation_policy {
    zones = [var.default_zone]
    instance_tags_pool {
      zone = var.default_zone
      tags  = ["lemp01","lemp02","lemp03"]
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
## Справка `https://yandex.cloud/ru/docs/compute/operations/instance-groups/create-with-balancer`
  load_balancer {
    target_group_name        = "lamp-group-lb"
  }
}

### Create Internal LoadBalancer
resource "yandex_lb_network_load_balancer" "internal-lb-lamp" {
  name = "external-lamp-lb"
  type = "external"
  deletion_protection = "false"
  folder_id = var.folder_id

  listener {
    name        = "lamp-listener"
    port        = 8081
    target_port = 80
    protocol    = "tcp"
    external_address_spec {
      address = yandex_vpc_address.lb-addr.external_ipv4_address[0].address
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer.0.target_group_id
    healthcheck {
      name                = "lamp"
      interval            = 5
      timeout             = 2
      unhealthy_threshold = 3
      healthy_threshold   = 2
      http_options {
        port = 80
        path = "/"
      }
    }
  }

  depends_on = [ yandex_compute_instance_group.lamp_group ]
}
