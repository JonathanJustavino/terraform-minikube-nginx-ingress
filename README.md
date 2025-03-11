# Terraform Nginx + Ingress

A terraform configuration that deploys a nginx with ingress
inside a minikube kubernetes cluster.

## Use

1. `terraform init`
2. `terraform apply`
3. type `yes`
4. Nginx server available under http://<MINIKUBE_IP>/:32323

## Prerequisites

1. running installation of [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download)
2. `minikube addons enable ingress`
