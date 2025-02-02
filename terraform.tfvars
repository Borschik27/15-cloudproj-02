vms_resources_nat = {
  nat-instance = {
    name          = "nat-instance"
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    hdd_size      = 30
    hdd_type      = "network-hdd"
    core_fraction = 50
    zone          = "ru-central1-a"
    hostname      = "nat-instance"
    nat_status    = "true"
    local_ip      = "192.168.10.254"
    cidr_block    = "192.168.10.0/24"
    services_image_id = "fd8lq67qr9o6fhjc64fl"
  }
}

vms_resources_public = {
  public-vm01 = {
    name          = "public-vm01"
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    hdd_size      = 30
    hdd_type      = "network-hdd"
    core_fraction = 50
    zone          = "ru-central1-a"
    hostname      = "public-vm01"
    nat_status    = "false"
    local_ip      = "192.168.10.88"
  }
}

vms_resources_private ={
  private-vm01 = {
    name          = "private-vm01"
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    hdd_size      = 30
    hdd_type      = "network-hdd"
    core_fraction = 50
    zone          = "ru-central1-a"
    hostname      = "private-vm01"
    nat_status    = "false"
    local_ip      = "192.168.20.66"
  }
}