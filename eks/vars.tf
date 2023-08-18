
variable "cluster_role" {
  type = string
  default = "cluster-role"
}

variable "nodegroup_role" {
  type = string
  default = "nodegroup-role"
}

variable "cluster_sg_id" {
  type = string
  default = "sg-0567bd877cbbaa376"
}

variable "nodegroup_sg_id" {
  type = string
  default = "sg-007d2537943943986"
}

variable "alb_sg_id" {
  type = string
  default = "sg-0fe2bd365af761958"
}

variable "vpc_id" {
  type = string
  default = "vpc-07beb0b3ac81f9db7"
}
