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

```bash
terraform apply
```

Deploy takes around 10-15 minutes.
All state changes will be saved in bucket `prod-holaplex-hub-tf-state`, so we can make modifications from different environments (local, github actions)

### Destroy

```bash
terraform destroy
```
