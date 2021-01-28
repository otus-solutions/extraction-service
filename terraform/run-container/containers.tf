variable "extraction-service-port"{ default = 51020 }
variable "extraction-service-name"{ default = "extraction-service:latest" }
variable "extraction-service-network"{ default = "otus-api-network" }
variable "extraction-service-memory"{ default = "1024" }
variable "api-port"{ default = "8080" }
variable "elasticsearch-hostname"{ default = "elasticsearch" }
variable "elasticsearch-port"{ default = "9200" }
variable "elasticsearch-protocol"{ default = "http" }
variable "elasticsearch-initialize"{ default = "false" }
resource "docker_image" "extraction-service" { name = var.extraction-service-name }

resource "null_resource" "network-creation" {
  provisioner "local-exec" {
    command = "docker network create ${var.extraction-service-network}"
    on_failure = continue
  }
}

resource "null_resource" "extraction-service-container-removal" {
  provisioner "local-exec" {
    command = "docker stop extraction-service"
    on_failure = continue
  }
  provisioner "local-exec" {
    command = "docker rm extraction-service"
    on_failure = continue
  }
}

resource "docker_container" "extraction-service" {
  depends_on = [null_resource.network-creation, null_resource.extraction-service-container-removal]
  name = "extraction-service"
  image = docker_image.extraction-service.name
  env = [
    "MEMORY=${var.extraction-service-memory}",
    "API_PORT=${var.api-port}",
    "ELASTICSEARCH_HOSTNAME=${var.elasticsearch-hostname}",
    "ELASTICSEARCH_PORT=${var.elasticsearch-port}",
    "ELASTICSEARCH_PROTOCOL=${var.elasticsearch-protocol}",
    "ELASTICSEARCH_INITIALIZE=${var.elasticsearch-initialize}",
  ]
  ports {
    internal = 8080
    external = var.extraction-service-port
  }
  networks_advanced {
    name = var.extraction-service-network
  }
}