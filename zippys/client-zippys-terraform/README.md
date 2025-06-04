# Azure Container App Behind Application Gateway — Bicep Deployment

This repository demonstrates how to deploy a sample containerized application on **Azure Container Apps (ACA)**, fronted by **Azure Application Gateway**, using **Bicep** as Infrastructure-as-Code.

---

## Prerequisites

### 1. Install Azure CLI

Install the Azure CLI from the official Microsoft guide:  
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

After installing, verify the installation:

```bash
az --version
```

### 2. Log in to Azure

Authenticate with your Azure account:

```bash
az login
```

If you're in a cloud shell, this is automatic.

To verify your active subscription:

```bash
az account show
```

---

## Deployment Instructions

Run the following command to deploy the infrastructure to your Azure **subscription**:

```bash
az deployment sub create \
  --location westus2 \
  --template-file main.bicep
```

Make sure you're targeting the correct subscription, and that you have the required permissions to create resources at the subscription level.

To deploy different environments:
- Switch to the prod branch to deploy the production environment
- Use the staging branch to deploy the staging environment
---

## Bicep Template Overview

### `main.bicep`

This is the entry point of the deployment. It defines:

#### Tags

```bicep
param tags object = {
  SampleName: 'aca-app-gateway'
  Owner: 'Zippys'
  Application: 'Azure-Samples'
  Environment: 'Stg'
}
```

These tags are applied to all deployed resources to support tracking, billing, and management.

#### Naming Convention

```bicep
@description('The suffix applied to all resources')
param appSuffix string = 'zipserve-stage'
```

This suffix is used to ensure globally unique and consistent resource names.

#### Resource Group

```bicep
var resourceGroupName = 'zip-serve-stg-be-rg'
```

This sets the name of the resource group that will contain all deployed resources.

---

### Container App Module

In `app-gw-aca/host/container-app.bicep`:

```bicep
@description('Specifies the docker container image to deploy.')
param containerImage string = 'thomaspoignant/hello-world-rest-json:latest'

@description('Specifies the container port.')
param targetPort int = 8080
```

These parameters define the container image and the port it will expose. The container will be deployed as a service inside Azure Container Apps.

---

## Project Structure

```
.
├── main.bicep
└── app-gw-aca/
    └── host/
        └── container-app.bicep
```

- `main.bicep`: root deployment template
- `container-app.bicep`: ACA-specific logic (container, port, ingress, etc.)

---

## Testing

After deployment, the Application Gateway will expose a public endpoint (if configured). You can test it by opening the DNS name or IP address in your browser.

For example:

```bash
curl http://<app-gateway-public-ip-or-dns>
```

You should see a JSON response from the sample container:

```json
{
  "status": "OK",
  "message": "HelloWorld"
}
```

---

## Cleanup

To remove all resources created during deployment:

```bash
az group delete \
  --name zip-serve-stg-be-rg \
  --yes --no-wait
```

This will delete all resources inside the resource group.

---

## Support / Contributions

This is a sample project. If you encounter issues:

- Check Azure CLI permissions
- Ensure correct container image
- Review Azure Region availability for ACA and App Gateway

---

## References

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/)
- [Bicep Language Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)


