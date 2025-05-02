# Head First !

A lot of things need to be done before we can create an application. 

1. Start with logging into the GCP
```shell
# Authenticate terraform via ADC
gcloud auth application-default login             # opens browser
gcloud config set project $(your_project_id)
```
2. Enable all related APIs
```shell
# Enables Required APIs (Make sure that you have linked w ur billing account)
gcloud services enable compute.googleapis.com container.googleapis.com 

```