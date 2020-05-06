variable project {
  type        = string
  description = "Project ID"
}

variable region {
  type        = string
  description = "Region"
}

variable zone {
  type        = string
  description = "Zone"
}

variable cluster_name {
  type        = string
  description = "Cluster name"
  default     = "cluster-1"
}

variable cluster_node_count {
  type        = number
  description = "Cluster node count"
}

variable pool_name {
  type        = string
  description = "Pool name"
  default     = "nodes-pool-1"
}

variable pool_node_count {
  type        = number
  description = "Pool node count"
}

variable "machine_type" {
  type        = string
  description = "Machine type"
  default     = "n1-standard-1"
}

variable tags {
  type        = list(string)
  description = "Node tags"
}

variable source_ranges {
  type        = list(string)
  description = "IP source range"
}

variable ports {
  type        = list(string)
  description = "Port range"
}
