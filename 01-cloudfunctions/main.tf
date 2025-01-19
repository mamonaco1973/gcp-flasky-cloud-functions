# Google Cloud Provider Configuration
# Configures the Google Cloud provider using project details and credentials from a JSON file.
provider "google" {
  project     = local.credentials.project_id             # Specifies the project ID from the decoded credentials file.
  credentials = file("../credentials.json")              # Path to the credentials JSON file for authentication.
}

# Local Variables
# Reads and decodes the credentials.json file to extract necessary details like project ID and service account email.
locals {
  credentials            = jsondecode(file("../credentials.json")) # Decodes the JSON file into a usable map structure.
  service_account_email  = local.credentials.client_email          # Extracts the service account email from the decoded JSON.
}

# Random ID Generation
# Generates a random 4-byte hexadecimal ID to ensure resource names are unique.
resource "random_id" "suffix" {
  byte_length = 4 # Specifies the number of bytes for the random ID.
}

# Cloud Storage Bucket Creation
# Creates a Google Cloud Storage bucket with a unique name for storing source files.
resource "google_storage_bucket" "flasky_bucket" {
  name     = "flasky-bucket-${random_id.suffix.hex}" # Constructs a unique bucket name using the random ID.
  location = "us-central1"                           # Specifies the region where the bucket is created.
}

# Upload Source Code to Storage Bucket
# Uploads the ZIP file containing source code to the created storage bucket.
resource "google_storage_bucket_object" "function_zip" {
  bucket = google_storage_bucket.flasky_bucket.name                   # The target bucket for the uploaded file.
  name   = "function-source-${filesha256("./functions.zip")}.zip"     # Names the file using a hash of its contents to avoid duplicates.
  source = "./functions.zip"                                          # Local path to the source code ZIP file.
}

# Deploy Cloud Functions Using a Loop
# Creates multiple Google Cloud Functions based on the `var.functions` map.
resource "google_cloudfunctions2_function" "functions" {
  for_each = var.functions # Iterates over the provided functions map to deploy each function.

  name     = each.key      # Name of the Cloud Function.
  location = "us-central1" # Specifies the region for the Cloud Function.

  # Build Configuration
  build_config {
    runtime     = "python311"            # Specifies the runtime environment (Python 3.11).
    entry_point = each.value.entry_point # Entry point function for the Cloud Function.

    # Source Code Configuration
    source {
      storage_source {
        bucket = google_storage_bucket_object.function_zip.bucket # References the storage bucket for the source code.
        object = google_storage_bucket_object.function_zip.name   # References the uploaded ZIP file.
      }
    }
  }

  # Service Configuration
  service_config {
    ingress_settings    = "ALLOW_ALL"              # Allows all traffic to access the Cloud Function.
    available_memory    = each.value.memory        # Allocates memory for the function.
    min_instance_count  = each.value.min_instances # Minimum number of instances to run.
    max_instance_count  = each.value.max_instances # Maximum number of instances to scale to.
    timeout_seconds     = each.value.timeout       # Maximum execution time for the function.
  }
}

# Anonymous Access for Each Function
# Grants public invocation permissions to the deployed Cloud Functions if `var.anonymous` is true.
resource "google_cloud_run_service_iam_member" "functions_iam" {
  for_each = var.anonymous ? var.functions : {}                           # Applies only when `var.anonymous` is true.
  location = google_cloudfunctions2_function.functions[each.key].location # Location of the Cloud Function.
  service  = google_cloudfunctions2_function.functions[each.key].name     # Name of the Cloud Function.
  role     = "roles/run.invoker"                                          # Role that allows invocation of the function.
  member   = "allUsers"                                                   # Grants public access to all users.
}

# Firestore IAM Member Configuration
# Assigns Firestore user role to the service account for accessing Firestore resources in the project.
resource "google_project_iam_member" "flask_firestore_access" {
  project = local.credentials.project_id                      # Specifies the project ID from local credentials.
  role    = "roles/datastore.user"                            # Role assigned to the member, allowing Firestore access.
  member  = "serviceAccount:${local.service_account_email}"   # Service account email receiving the role.
}
