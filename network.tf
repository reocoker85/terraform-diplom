resource "yandex_vpc_network" "my_vpc" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.subnet_public_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_vpc.id
  v4_cidr_blocks = var.public_cidr
}

resource "yandex_vpc_subnet" "my_subnet" {
  count          = length(var.zones)
  name           = "${var.subnet_name}-${var.zones[count.index]}"
  v4_cidr_blocks = [cidrsubnet(var.cidr[0], 2, count.index)]
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.my_vpc.id
}

