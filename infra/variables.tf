variable "aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "db_host" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "shopdb"
}

variable "backend_image" {
  type = string
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "desired_count" {
  type    = number
  default = 1
}