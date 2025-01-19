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

resource "random_id" "suffix" {
  byte_length = 4
}

# Create a Cloud Storage bucket

resource "google_storage_bucket" "flasky_bucket" {
  name = "flasky-bucket-${random_id.suffix.hex}"
  location = "us-central1"
}

# Upload the zip file to the bucket

resource "google_storage_bucket_object" "function_zip" {
  bucket = google_storage_bucket.flasky_bucket.name
  name   = "function-source-${filesha256("./functions.zip")}.zip"
  source = "./functions.zip" 
}

# Deploy Cloud Functions Using for_each loop

resource "google_cloudfunctions2_function" "functions" {

  for_each = var.functions

  name     = each.key
  location = "us-central1"

  build_config {
    runtime     = "python311"
    entry_point = each.value.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket_object.function_zip.bucket
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    ingress_settings    = "ALLOW_ALL"
    available_memory    = each.value.memory
    min_instance_count  = each.value.min_instances
    max_instance_count  = each.value.max_instances
    timeout_seconds     = each.value.timeout
  }
}

# Anonymous access for Each Function
resource "google_cloud_run_service_iam_member" "functions_iam" {
  for_each = var.anonymous ? var.functions : {}
  location = google_cloudfunctions2_function.functions[each.key].location
  service  = google_cloudfunctions2_function.functions[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


# IAM Member: Firestore Access
# Grants the Firestore user role to the specified service account for the project.
resource "google_project_iam_member" "flask_firestore_access" {
  project = local.credentials.project_id                      # Specifies the project ID from local credentials.
  role    = "roles/datastore.user"                            # Role assigned to the member, allowing Firestore access.
  member  = "serviceAccount:${local.service_account_email}"   # Service account email receiving the role.
}

