variable "aws_region" {
  default = "us-east-1"
}

variable "ssh_key_name" {
  description = "Nombre de tu llave .pem en AWS"
}

variable "docker_user" {
  description = "Usuario de Docker Hub"
}

variable "bucket_logs" {
  default = "json-rest-mauro28102023"
}

# Este es el nombre del bucket que ya creaste a mano en la consola
variable "bucket_terraform" {
  default = "examen-suple-rest-mauro28102023"
}

# Variables para las credenciales de AWS Academy (inyectadas por GitHub)
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_session_token" {}