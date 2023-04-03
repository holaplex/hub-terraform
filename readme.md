# Dependencies

- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- gcloud terraform module `gcloud components install terraform-tools`

### Prepare workspace

Login to GCP

```bash
gcloud auth application-default login --project prod-holaplex-hub
```

Initialize backend

```bash
terraform init
```

output:

```text
Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes
```

### Deploy

Run terraform plan and validate the output.

```bash
terraform plan
```

Deploy when ready:

```bash
terraform apply
```

Deploy takes around 10-15 minutes.
All state changes will be saved in bucket `prod-holaplex-hub-tf-state`, so we can make modifications from different environments (local, github actions)

### Connect to the deployed cluster

```bash
gcloud auth login
gcloud config set project prod-holaplex-hub
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials prod-holaplex-usc-gke --region us-central1 --project prod-holaplex-hub
```

### Validate

```bash
kubectl get nodes --context gke_prod-holaplex-hub_us-central1_prod-holaplex-usc-gke
```
