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
  default = "examen-suple-rest-mauro28102023"
}

variable "bucket_terraform" {
  default = "examen-suple-grpc-2026"
}