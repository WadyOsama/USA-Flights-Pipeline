variable "credentials_file_path" {
  description = "Path to the GCP credentials file"
  type        = string
  default     = "./Keys/gcp_creds.json"
  
}

variable "credentials_file_name" {
  description = "Name of the GCP credentials file"
  type        = string
  default     = "gcp_creds.json"
  
}

# replace this with your own project id
variable "project_id" {
  description = "Project ID for the GCP project"
  type        = string
  default = "eighth-edge-289309"
}

variable "region_name" {
  description = "Region name for the pipeline"
  type        = string
  default     = "europe-west1"
  
}

variable "zone_name" {
  description = "Zone name for the pipeline"
  type        = string
  default     = "europe-west1-b"
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "usa-flights-orch-kestra"
}

variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
  default     = "usa_flights_dezoomcamp_project"
  
}

variable "dataset_name" {
  description = "Name of the BigQuery dataset"
  type        = string
  default     = "usa_flights_dezoomcamp_project"
  
}

variable "service_account_email" {
  description = "service account email"
  type        = string
  default = "terraforn-runner@eighth-edge-289309.iam.gserviceaccount.com"
}

variable "pipeline_script_path" {
  description = "Path to the pipeline init script"
  type        = string
  default     = "./Assets/run_kestra.sh"
}

variable "pipeline_script_name" {
  description = "Name of the pipeline init script"
  type        = string
  default     = "run_kestra.sh"
  
}

variable "kestra_flow_path" {
  description = "Path to the Kestra flow YAML file"
  type        = string
  default     = "./Assets/kestra_flow.yaml"
  
}

variable "kestra_flow_name" {
  description = "Name of the Kestra flow YAML file"
  type        = string
  default     = "kestra_flow.yaml"
  
}

variable "ssh_user" {
  description = "SSH user for the VM instance"
  type        = string
  default     = "wady"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
  
}