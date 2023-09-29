### Local Dependencies

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
# enable Secrets Manager API
gcloud services enable secretmanager.googleapis.com
# enable Certificate Manager API
gcloud services enable certificatemanager.googleapis.com
# Enable redis - memory store API
gcloud services enable redis.googleapis.com
```

### Preparing our workspace

Create a cloud bucket to store our terraform state.

```bash
bucket_name=name-of-tf-state-bucket
gcloud storage buckets create gs://$bucket_name \
 --default-storage-class=STANDARD \
 --location=us \
 --uniform-bucket-level-access
 #enable versioning && apply lifecycle rules
 gcloud storage buckets update gs://$bucket_name --versioning --lifecycle-file=bucket-lifecycle.json
```

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

### Configure DNS

After completion, you should see a DNS challenge that you'll need to configure on your DNS provider in order to generate a wildcard certificate for the Hub domains.
Ex:

```
Outputs:
dns_record_name = "_acme-challenge.holaplex.com."
dns_cname_value = "eb6fc218-9aeq-4c5e-8fe8-80737afa31oa.19.authorize.certificatemanager.goog."
```

Add a CNAME record with those values before continuing.

> If using Google DNS, remove the domain and ending dot from the dns_record_value, so instead of `_acme-challenge.holaplex.com.` you'll add `_acme-challenge`

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

### Save SQL instance users/passwords in Google secret Manager

Open `./create-secrets.sh`, change the bucket name with your own and execute it to create a secret for each SQL instance you created.

```bash
IFS=$'\n'
credentials=$(gsutil cat gs://$bucket_name/terraform/state/default.tfstate \
  | jq -r '.resources[].instances[].attributes | {instance: .instance, username: .name, password: .password } | select(.password != null) | [.instance, .username, .password] | @tsv')
for line in $credentials; do
  IFS=$'\t' read -ra values <<< "$line"
  instance="${values[0]}"
  username="${values[1]}"
  password="${values[2]}"

  echo -ne "$password" | gcloud secrets create "$instance-db-creds" --data-file=- --labels=user="$username"
  IFS=$'\n'
done
```

You should see a secret for each instance in [Secret Manager](https://console.cloud.google.com/security/secret-manager)

### Deploy automated backups

- Install [Velero CLI](https://github.com/vmware-tanzu/velero/releases/tag/v1.10.2)
- Replace the values below with your own (set in `values.yaml`)

```bash
#kubernetes.backups.service.namespace
NAMESPACE=velero
#kubernetes.backups.service.name
KSA_NAME=velero
GSA_NAME=velero
#project.name
PROJECT_ID=prod-holaplex-hub
#kubernetes.backups.bucket.name
BUCKET=prod-holaplex-usc-gke-velero
#Create namespace
kubectl create namespace $NAMESPACE
#Deploy
velero install \
  --namespace $NAMESPACE \
  --provider gcp \
  --plugins velero/velero-plugin-for-gcp:v1.6.0 \
  --bucket $BUCKET \
  --no-secret \
  --sa-annotations iam.gke.io/gcp-service-account=$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --backup-location-config serviceAccount=$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --wait
```

Setup a backup schedule:

```bash
velero schedule create daily-backups --schedule="0 3 * * *"
```

Initial setup is complete.
If going to prod, continue with:
[Deploying a Fireblocks Co-signer VM in Azure](./co-signer)

If not, head over to [hub-kubes/external-secrets](https://github.com/holaplex/hub-kubes/blob/main/infra/external-secrets) to continue deploying.
