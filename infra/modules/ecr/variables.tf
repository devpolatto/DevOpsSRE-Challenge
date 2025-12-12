variable "repository" {
  type = object({
    name                 = string
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
  })
}

variable "enabled_resource" {
  description = "Enable or disable the resource"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}