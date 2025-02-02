variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "services_acc_id" {
  type        = string
}

variable "default_zone" {
  type        = string
}

variable "vms_ssh_root_key" {
  type        = string 
}

variable "vms_ssh_root_key_file" {
  type        = string 
}

variable "ppkyc" {
  type        = string
  description = "Path to key"
}

variable "default_platform_id" {
  type        = string
  description = "Platform ID"
}

variable "default_image_family" {
  type        = string
  description = "ISO-img family"
}

variable "default_vm_user" {
  description = "Username for the VM user"
  type        = string
}

variable "default_vm_user_password" {
  description = "Password for the VM user"
  type        = string
}

variable "sudo_vm_u_group" {
  description = "User group for the VM user"
  type        = string
}

variable "default_vm_u_shell" {
  description = "Shell for the VM user"
  type        = string
}

variable "sudo_cloud_init" {
  description = "Sudo permissions for the user"
  type        = string
}

variable "pack_list" {
  description = "List of packages to install via Cloud-init"
  type        = list(string)
  default     = []
}

variable "vpc_name" {
  description = "Virtual network name"
  type        = string
}

variable "subnet_name1" {
  description = "Subnet name public"
  type        = string
}

variable "subnet_name2" {
  description = "Subnet name private"
  type        = string
}

variable "public_cidr" {
  description = "CIDR public"
  type        = list(string)
}

variable "private_cidr" {
  description = "CIDR private"
  type        = list(string)
}

variable "sg_nat_name" {
  description = "Security group name"
  type        = string
}

variable "route_table_name" {
  description = "Route table name"
  type        = string
}

### LEMP Variables
variable "lemp_name_group" {
  description = "VM Group name"
  type        = string
}

variable "lemp_memory" {
  description = "lemp group vm mem"
  type        = string
}

variable "lemp_cores" {
  description = "lemp group vm core"
  type        = string
}

variable "lemp_core_fraction" {
  description = "lemp group vm core fraction"
  type        = string
}

variable "lemp_hdd_size" {
  description = "lemp group vm disk size"
  type        = string
}

variable "lemp_hdd_type" {
  description = "lemp group vm disk type"
  type        = string
}

variable "lemp_image_id" {
  description = "lemp image id"
  type        = string
}

### For masive install mv terraform.tfvars
variable "vms_resources_nat" {
  type = map(object({
    name          = string
    cores         = number
    memory        = number
    hdd_size      = number
    hdd_type      = string
    core_fraction = number
    platform_id   = string
    zone          = string
    hostname      = string
    nat_status    = string
    local_ip      = string
    services_image_id = string
  }))
}

variable "vms_resources_public" {
  type = map(object({
    name          = string
    cores         = number
    memory        = number
    hdd_size      = number
    hdd_type      = string
    core_fraction = number
    platform_id   = string
    zone          = string
    hostname      = string
    nat_status    = string
    local_ip      = string
  }))
}

variable "vms_resources_private" {
  type = map(object({
    name          = string
    cores         = number
    memory        = number
    hdd_size      = number
    hdd_type      = string
    core_fraction = number
    platform_id   = string
    zone          = string
    hostname      = string
    nat_status    = string
    local_ip      = string
  }))
}
### End each vms_resources

### Bucket
variable "bucket_name" {
  description = "Name object storage"
  type        = string
}

variable "image_path" {
  description = "Path file"
  type        = string
}