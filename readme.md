# Local Dependencies

- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- gcloud terraform module `gcloud components install terraform-tools`

### Deployment dependencies

If this is the first time using the GCP account, you'll need to enable the required APIs first.

```bash
gcloud auth login
gcloud config set project prod-holaplex-hub
gcloud config set compute/region us-central1
# enable Kubernetes API
gcloud services enable container.googleapis.com
# enable CloudSQL API
gcloud  services enable sqladmin.googleapis.com
# enable Compute API
gcloud services enable compute.googleapis.com
# enable Service Networking API
gcloud services enable servicenetworking.googleapis.com
```

### Prepare workspace

Auth Terraform to GCP

```bash
gcloud auth application-default login
```

Make sure the output of this command mentions the project you want to make changes to. Example:

```text
Quota project "prod-holaplex-hub" was added to ADC.
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

Open `values.yaml` and modify it to suit your needs. If need to upgrade SQL instance size or add more, just modify the sqlInstances array. Save and exit.

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
gcloud components install gke-gcloud-auth-plugin
#Change ~/.bash_profile for the correct one if using a different shell
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> ~/.bash_profile
gcloud container clusters get-credentials prod-holaplex-usc-gke
#Simplify context name (rename to GKE cluster name, remove project and region)
sed -i.bak 's/gke_prod-holaplex-hub_us-central1_//g' $KUBECONFIG
```

### Validate

```bash
kubectl get nodes --context prod-holaplex-usc-gke
```
