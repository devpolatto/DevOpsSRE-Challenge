variable "repository" {
  type = object({
    name                 = string
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}