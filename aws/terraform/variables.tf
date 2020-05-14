variable "region" {}

variable "environment" {
  description = "Deployment environment."
}

variable "assumable_by_account_ids" {
  type        = list(string)
  description = "A list of IDs of AWS accounts (eg, egeodesy-dev) that are allowed to assume this role."
  default     = ["094928090547"]
}
