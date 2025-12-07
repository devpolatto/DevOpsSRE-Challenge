variable "aurora" {
  type = object({
    name              = string
    engine            = optional(string, "aurora-postgresql")
    engine_mode       = optional(string, "provisioned")
    engine_version    = optional(string, "17.4")
    database_name     = optional(string, "defaultdb")
    master_username   = optional(string, "adminuser")
    storage_encrypted = optional(bool, true)
    kms_key_id        = optional(string, "")
  })
}

variable "network" {
  type = object({
    db_subnet_group_name   = optional(string, "")
    vpc_security_group_ids = optional(list(string), [])
  })
}

variable "write_cluster_instence" {
  type = object({
    enabled                      = bool
    instance_class               = optional(string, "db.serverless")
    performance_insights_enabled = optional(bool, true)
  })
}

variable "reader_cluster_instence" {
  type = object({
    enabled                      = bool
    instance_class               = optional(string, "db.serverless")
    performance_insights_enabled = optional(bool, true)
  })
}

variable "secret" {
  type = object({
    secret_name             = string
    recovery_window_in_days = optional(number, 0)
  })
}

# variable "security_group" {
#   type = object({
#     vpc_id = string
#   })
# }

variable "tags" {
  type = map(string)
}