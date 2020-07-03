
variable "name" {
  description = "Regex to apply to all resources in the module"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Define tags"
  type        = map(string)
}
