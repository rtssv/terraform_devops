variable "zone" {                                # Используем переменную для передачи в конфиг инфраструктуры
  description = "Use specific availability zone" # Опционально описание переменной
  type        = string                           # Опционально тип переменной
  default     = "ru-central1-b"                  # Опционально значение по умолчанию для переменной
}

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.60.0" # Фиксируем версию провайдера
    }
  }
}

variable "token" {}
variable "cloud_id" {}
variable "folder_id" {}

# Документация к провайдеру тут https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs#configuration-reference
# Настраиваем the Yandex.Cloud provider
provider "yandex" {
    token                    = var.token
    cloud_id                 = var.cloud_id
    folder_id                = var.folder_id
    zone                     = var.zone # зона, которая будет использована по умолчанию
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

module "ya_instance_1" {
  source                = "./module/instance"
  instance_family_image = "ubuntu-2004-lts"
  name                  = "master"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id
}

module "ya_instance_2" {
  source                = "./module/instance"
  instance_family_image = "ubuntu-2004-lts"
  name                  = "app"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id
}

module "ya_instance_3" {
  source                = "./module/instance"
  instance_family_image = "ubuntu-2004-lts"
  name                  = "srv"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id
}
