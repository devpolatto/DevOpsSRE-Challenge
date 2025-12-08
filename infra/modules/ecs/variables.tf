locals {
  task_ssm_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "ecr" {
  type = object({
    repository_url = string
  })
}

variable "network" {
  type = object({
    subnets                        = list(string)
    security_groups                = list(string)
    assign_public_ip               = optional(bool, false)
    load_balancer_target_group_arn = string
  })
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [{
    name  = ""
    value = ""
  }]
}

variable "secrets" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [{
    name  = ""
    value = ""
  }]
}

variable "task_definition" {
  type = object({
    name           = string
    container_name = string
    container_port = number
    cpu            = optional(number, 512)
    memory         = optional(number, 1024)
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}