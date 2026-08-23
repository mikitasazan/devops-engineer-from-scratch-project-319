resource "yandex_vpc_network" "this" {
  name = "${var.cluster_name}-network"
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.cluster_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = ["10.20.0.0/24"]
}

resource "yandex_iam_service_account" "cluster" {
  name = "${var.cluster_name}-cluster"
}

resource "yandex_iam_service_account" "nodes" {
  name = "${var.cluster_name}-nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster_editor" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "node_editor" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.nodes.id}"
}

resource "yandex_kubernetes_cluster" "this" {
  name        = var.cluster_name
  description = "Managed Kubernetes cluster for the bulletin board"
  network_id  = yandex_vpc_network.this.id

  master {
    version   = "1.30"
    public_ip = true

    master_location {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.this.id
    }
  }

  service_account_id       = yandex_iam_service_account.cluster.id
  node_service_account_id = yandex_iam_service_account.nodes.id
  release_channel          = "STABLE"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.cluster_editor,
    yandex_resourcemanager_folder_iam_member.node_editor,
  ]
}

resource "yandex_kubernetes_node_group" "this" {
  cluster_id = yandex_kubernetes_cluster.this.id
  name       = "${var.cluster_name}-nodes"

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores  = 2
      memory = 4
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.this.id]
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }
}

resource "yandex_mdb_postgresql_cluster" "this" {
  name        = "${var.cluster_name}-db"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.this.id

  config {
    version = "16"
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.this.id
    assign_public_ip = false
  }
}

resource "yandex_mdb_postgresql_database" "app" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = "bulletins"
  owner      = yandex_mdb_postgresql_user.app.name
}

resource "yandex_mdb_postgresql_user" "app" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = "bulletins"
  password   = var.db_password
}

resource "yandex_storage_bucket" "app" {
  bucket     = var.bucket_name
  access_key = var.storage_access_key
  secret_key = var.storage_secret_key
}

resource "yandex_lockbox_secret" "app" {
  name        = "${var.cluster_name}-secrets"
  description = "Runtime secrets for the bulletin board"
}
