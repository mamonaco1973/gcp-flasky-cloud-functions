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

resource "google_storage_bucket_object" "gtg_zip" {
  bucket = google_storage_bucket.flasky_bucket.name
  name   = "function-source-${filesha256("./functions.zip")}.zip"
  source = "./functions.zip" 
}

# Deploy the HTTP-triggered v2 Cloud Function
resource "google_cloudfunctions2_function" "gtg_function" {
  name     = "gtg"
  location = "us-central1" # Replace with your desired region

  build_config {
    runtime     = "python311" # Specify the Python 3.11 runtime
    entry_point = "gtg"       # Entry point in your Python code

    source {
      storage_source {
        bucket = google_storage_bucket_object.gtg_zip.bucket
        object = google_storage_bucket_object.gtg_zip.name
      }
    }
  }

  service_config {
    ingress_settings    = "ALLOW_ALL" # Allow all HTTP traffic; restrict as needed
    available_memory    = "256M"
    min_instance_count  = 0 
    max_instance_count  = 2
    timeout_seconds     = 60
  }
}

resource "google_cloud_run_service_iam_member" "gtg_member" {
  location = google_cloudfunctions2_function.gtg_function.location
  service  = google_cloudfunctions2_function.gtg_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Deploy the HTTP-triggered v2 Cloud Function
resource "google_cloudfunctions2_function" "candidates_function" {
  name     = "candidates"
  location = "us-central1" # Replace with your desired region

  build_config {
    runtime     = "python311"        # Specify the Python 3.11 runtime
    entry_point = "candidates"       # Entry point in your Python code

    source {
      storage_source {
        bucket = google_storage_bucket_object.gtg_zip.bucket
        object = google_storage_bucket_object.gtg_zip.name
      }
    }
  }

  service_config {
    ingress_settings    = "ALLOW_ALL" # Allow all HTTP traffic; restrict as needed
    available_memory    = "256M"
    min_instance_count  = 0 
    max_instance_count  = 2
    timeout_seconds     = 60
  }
}

resource "google_cloud_run_service_iam_member" "candidates_member" {
  location = google_cloudfunctions2_function.candidates_function.location
  service  = google_cloudfunctions2_function.candidates_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Deploy the HTTP-triggered v2 Cloud Function
resource "google_cloudfunctions2_function" "candidate_function" {
  name     = "candidate"
  location = "us-central1" # Replace with your desired region

  build_config {
    runtime     = "python311"        # Specify the Python 3.11 runtime
    entry_point = "candidate"        # Entry point in your Python code

    source {
      storage_source {
        bucket = google_storage_bucket_object.gtg_zip.bucket
        object = google_storage_bucket_object.gtg_zip.name
      }
    }
  }

  service_config {
    ingress_settings    = "ALLOW_ALL" # Allow all HTTP traffic; restrict as needed
    available_memory    = "256M"
    min_instance_count  = 0 
    max_instance_count  = 2
    timeout_seconds     = 60
  }
}

resource "google_cloud_run_service_iam_member" "candidate_member" {
  location = google_cloudfunctions2_function.candidate_function.location
  service  = google_cloudfunctions2_function.candidate_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

