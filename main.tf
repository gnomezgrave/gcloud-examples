provider "google" {
  project = "trv-hs-src-consolidation-test"
  region  = "europe-west1"
  zone    = "europe-west1-c"
  credentials = "${file("ppeiris-sa.json")}"
}

resource "google_cloudfunctions_function" "ppeiris-sub-fn" {
    name                      = "ppeiris-sub-fn"
    entry_point               = "sub_method"
    available_memory_mb       = 128
    timeout                   = 61
    project                   = "trv-hs-src-consolidation-test"
    region                    = "europe-west1"
    event_trigger             {
                                  event_type = "google.pubsub.topic.publish"
                                  resource = "${google_pubsub_topic.ppeiris-test-pubsub.name}"
                                }
    source_archive_bucket     = "${google_storage_bucket.ppeiris_bucket_testing.name}"
    source_archive_object     = "${google_storage_bucket_object.archive.name}"
    runtime                   = "python37"
    labels                    = {
                                  deployment_name           = "test"
                                }
}

resource "google_cloudfunctions_function" "ppeiris-pub-fn" {
    name                      = "ppeiris-pub-fn"
    entry_point               = "pub_method"
    available_memory_mb       = 128
    timeout                   = 61
    project                   = "trv-hs-src-consolidation-test"
    region                    = "europe-west1"
    trigger_http              = true
    source_archive_bucket     = "${google_storage_bucket.ppeiris_bucket_testing.name}"
    source_archive_object     = "${google_storage_bucket_object.archive.name}"
    runtime                   = "python37"
    labels                    = {
                                  deployment_name           = "test"
                                }
    environment_variables     = {
                                TOPIC = "${google_pubsub_topic.ppeiris-test-pubsub.name}"
                              }  
}

resource "google_pubsub_topic" "ppeiris-test-pubsub" {
  name      = "ppeiris-test-pubsub"
  project   = "trv-hs-src-consolidation-test"
}


resource "google_storage_bucket" "ppeiris_bucket_testing" {
  name = "ppeiris_bucket_testing"
}
 
data "archive_file" "test_function" {
  type        = "zip"
  output_path = "${path.module}/.files/main.zip"
  source {
    content  = "${file("${path.module}/main.py")}"
    filename = "main.py"
  }
}
 
resource "google_storage_bucket_object" "archive" {
  name   = "test_function.zip"
  bucket = "${google_storage_bucket.ppeiris_bucket_testing.name}"
  source = "${path.module}/.files/main.zip"
  depends_on = ["data.archive_file.test_function"]
}
 