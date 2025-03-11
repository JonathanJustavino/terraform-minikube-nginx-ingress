variable "ingress-service-name" {
  type    = string
  default = "ingress-service"
}

variable "ingress" {
  type    = string
  default = "ingress"
}

variable "deployment-name" {
  type    = string
  default = "my-cool-deployment"
}

variable "namespace" {
  type    = string
  default = "my-fancy-namespace"
}

variable "container_name" {
  type    = string
  default = "nginx"
}

variable "app_label" {
  type    = string
  default = "nginx"
}

variable "nginx-image-version" {
  type    = string
  default = "nginx:1.14.2"
}