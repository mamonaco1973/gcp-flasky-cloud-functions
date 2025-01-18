# Variables for Function Configuration
variable "functions" {
  default = {
    gtg = {
      entry_point  = "gtg"
      memory       = "256M"
      min_instances = 0
      max_instances = 2
      timeout       = 60
    }
    candidates = {
      entry_point  = "candidates"
      memory       = "256M"
      min_instances = 0
      max_instances = 2
      timeout       = 60
    }
    candidate = {
      entry_point  = "candidate"
      memory       = "256M"
      min_instances = 0
      max_instances = 2
      timeout       = 60
    }
  }
}