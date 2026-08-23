variable "yc_token" {
  description = "Yandex Cloud IAM token. Set YC_TOKEN in the environment."
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID."
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID."
  type        = string
}

variable "zone" {
  description = "Availability zone for the development subnet."
  type        = string
  default     = "ru-central1-a"
}

variable "cluster_name" {
  description = "Name shared by the infrastructure resources."
  type        = string
  default     = "bulletin-board"
}

variable "bucket_name" {
  description = "Globally unique Object Storage bucket name."
  type        = string
}

variable "db_password" {
  description = "Password for the application PostgreSQL user."
  type        = string
  sensitive   = true
}

variable "storage_access_key" {
  description = "Object Storage access key."
  type        = string
  sensitive   = true
}

variable "storage_secret_key" {
  description = "Object Storage secret key."
  type        = string
  sensitive   = true
}
