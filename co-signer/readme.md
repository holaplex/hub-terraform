### Dependencies

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos)

```bash
az login
```

### Register Azure resource providers

[Guide on Azure docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider?tabs=azure-portal#solution)

- Microsoft.Network
- Microsoft.Compute
- Microsoft.Storage

```bash
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
```

### Deploy

```bash
terraform plan
terraform apply
```
