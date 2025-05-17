/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_storage_bucket" "media" {
  name = var.random_suffix ? "media-${var.project_id}-${random_id.suffix.hex}" : "media-${var.project_id}"

  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  labels = var.labels
}

resource "google_storage_bucket_iam_member" "server" {
  bucket = google_storage_bucket.media.name
  member = "serviceAccount:${google_service_account.server.email}"
  role   = "roles/storage.admin"
}

resource "google_storage_bucket" "frontend_assets" {
  name          = var.random_suffix ? "frontend-${var.project_id}-${random_id.suffix.hex}" : "frontend-${var.project_id}"
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html" # Or a specific 404 page if you have one
  }

  labels = var.labels
}

resource "google_storage_bucket_iam_member" "frontend_public_access" {
  bucket = google_storage_bucket.frontend_assets.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "automation" {
  bucket = google_storage_bucket.media.name
  member = "serviceAccount:${google_service_account.automation.email}"
  role   = "roles/storage.admin"
}
