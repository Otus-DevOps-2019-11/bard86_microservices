variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west3"
}

variable zone {
  description = "Zone"
  default     = "europe-west3-a"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
  default = "ubuntu-1604-xenial-v20200129"
}

variable instance_count {
  description = "number of instances"
  default     = "2"
}
