
provider "google" {
  credentials = file(var.credentials)
  project     = var.gcp_project
  region      = var.region
}

//Create vpc
resource "google_compute_network" "vpc" {
  name = "tf-vpc-network"
  auto_create_subnetworks = "false"
}

//Create subnet


resource "google_compute_firewall" "firewall-vpc" {
  name    = "tf-firewall"
  network = google_compute_network.vpc.name

  # allow {
  #   protocol = "icmp"
  # }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

   allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}


resource "google_compute_global_address" "private_ip_block" {
  name         = "private-ip-block"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "tf-subnetwork1"
  ip_cidr_range = var.subnet_1_CIDR
  region        = var.region
  network       = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "tf-subnetwork2"
  ip_cidr_range = var.subnet_2_CIDR
  region        = var.region
  network       = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]
}

resource "google_compute_subnetwork" "subnet3" {
  name          = "tf-subnetwork3"
  ip_cidr_range = var.subnet_3_CIDR
  region        = var.region
  network       = google_compute_network.vpc.name
  depends_on = [google_compute_network.vpc]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  count = 3
  name   = "private-instance-${count.index + 1}-${random_id.db_name_suffix.hex}"
  database_version = "MYSQL_8_0"
  region = var.region
  deletion_protection = false
  depends_on = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10  # 10 GB is the smallest disk size
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
    }
    backup_configuration {
      enabled=false
      binary_log_enabled = false

    }
  }
}


resource "google_sql_user" "db_user" {
  count = 3
  name     = var.cloud_sql_user
  instance = "private-instance-${count.index + 1}-${random_id.db_name_suffix.hex}"
  password = var.cloud_sql_password
  depends_on = [google_sql_database_instance.instance]
}

resource "google_sql_database" "database" {
  count = 3
  name     = var.cloud_sql_db_names[count.index]
  instance = "private-instance-${count.index + 1}-${random_id.db_name_suffix.hex}"
  depends_on = [google_sql_database_instance.instance]
}

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = var.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-east4"
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  # node_locations   = ["${coalescelist(compact(var.zones), sort(random_shuffle.available_zones.result))}"]

  # master_auth {
  #   username = ""
  #   password = ""

  #   client_certificate_config {
  #     issue_client_certificate = false
  #   }
  # }
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.17.0.0/28"
  }
  network = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet1.name
  logging_service    = "none"
  monitoring_service = "none"

   ip_allocation_policy {
  #   cluster_secondary_range_name  = "us-east4-01-gke-01-pods"
  #   services_secondary_range_name = "us-east4-01-gke-01-services"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
      display_name = "allowAll"
    }
  }
}


resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = "us-east4"
  cluster    = google_container_cluster.primary.name
  # initial_node_count = 1
  node_count = 1
  autoscaling {
    max_node_count = 4
    min_node_count = 1
  }
  node_config {
    disk_size_gb = 32
    preemptible  = true
    machine_type = "e2-medium"
    image_type= "Ubuntu"
    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

