terraform {
  backend "gcs" {
    bucket = "otus-devops-dbarsukov-gitlabci"
    prefix = "terraform/state"
  }
}
