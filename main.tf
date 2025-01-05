
data "yandex_iam_service_account" "existing_sa" {
  service_account_id = var.sa_id
}

resource "yandex_compute_instance_group" "groups" {
  for_each = var.instance_groups

  name                = "${each.value.name_prefix}-group"
  service_account_id  = data.yandex_iam_service_account.existing_sa.id
  deletion_protection = false

  instance_template {
    name        = "${each.value.name_vm}-{instance.index}"
    platform_id = each.value.platform_id
    resources {
      cores         = each.value.cores
      memory        = each.value.memory
      core_fraction = each.value.core_fraction
    }

    scheduling_policy {
      preemptible = each.value.preemptible
    }

    boot_disk {
      initialize_params {
        image_id = each.value.image_id
      }
    }

    network_interface {
      network_id = yandex_vpc_network.my_vpc.id
      subnet_ids = [
        yandex_vpc_subnet.my_subnet[0].id,
        yandex_vpc_subnet.my_subnet[1].id,
        yandex_vpc_subnet.my_subnet[2].id
      ]
      nat = each.value.nat
    }

    metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
    }

    network_settings {
      type = each.value.ns_type
    }
  }

  scale_policy {
    fixed_scale {
      size = each.value.fix_size
    }
  }

  allocation_policy {
    zones = each.value.zones
  }

  deploy_policy {
    max_unavailable = each.value.max_unavailable
    max_creating    = each.value.max_creating
    max_deleting    = each.value.max_deleting
    max_expansion   = each.value.max_expansion
  }

}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yaml")

  vars = {
    ssh_public_key = file("~/.ssh/id_ed25519.pub")
  }
}
