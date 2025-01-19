
# Variable Definitions for Cloud Function Configuration

# Map variable for defining multiple Cloud Functions
# Each key represents a Cloud Function, and its value is a map containing configuration details.
variable "functions" {
  default = {
    # Configuration for the 'gtg' Cloud Function
    gtg = {
      entry_point  = "gtg"        # Entry point function name in the source code.
      memory       = "256M"       # Allocates 256MB of memory for the function.
      min_instances = 0           # Minimum number of instances to keep warm (set to 0 for cost efficiency).
      max_instances = 2           # Maximum number of instances allowed during scaling.
      timeout       = 60          # Maximum function execution time in seconds.
    }

    # Configuration for the 'candidates' Cloud Function
    candidates = {
      entry_point  = "candidates" # Entry point function name in the source code.
      memory       = "256M"       # Allocates 256MB of memory for the function.
      min_instances = 0           # Minimum number of instances to keep warm (set to 0 for cost efficiency).
      max_instances = 2           # Maximum number of instances allowed during scaling.
      timeout       = 60          # Maximum function execution time in seconds.
    }

    # Configuration for the 'candidate' Cloud Function
    candidate = {
      entry_point  = "candidate"  # Entry point function name in the source code.
      memory       = "256M"       # Allocates 256MB of memory for the function.
      min_instances = 0           # Minimum number of instances to keep warm (set to 0 for cost efficiency).
      max_instances = 2           # Maximum number of instances allowed during scaling.
      timeout       = 60          # Maximum function execution time in seconds.
    }
  }
}

# Boolean Variable for Anonymous Access
# Determines whether to enable anonymous access to the deployed Cloud Functions (public invocation).
variable "anonymous" {
  description = "Enable anonymous access to Cloud Functions (allUsers can invoke the functions)" # Description of the variable.
  type        = bool  # Data type of the variable (boolean).
  default     = true  # Default value set to 'true' to allow public invocation.
}
