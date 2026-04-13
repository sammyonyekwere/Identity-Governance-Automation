# Identity Governance Automation Portfolio Project

This repository demonstrates Infrastructure as Code (IaC) principles to automate Identity Governance operations in an Azure Environment using Bicep.

## Overview

The solution consists of three main components:
1. **PIM Role Activation** (`modules/rbac-pim.bicep`): Configures Azure AD Privileged Identity Management (PIM) to grant eligible access rather than permanent role assignments.
2. **Access Reviews** (`modules/access-reviews.bicep`): Implements recurring attestation to verify if users still require their privileged roles. Currently configured for self-review.
3. **Privilege Escalation Alerts** (`modules/alerts.bicep`): Provisions an Azure Monitor Activity Log Alert that watches for new Role Assignments over the subscription and alerts an Action Group via email to warn of potential privilege escalation.

## Getting Started

### Prerequisites

*   An Azure Subscription
*   Azure CLI installed
*   Owner or Role Based Access Control Administrator permissions over the Subscription (to assign PIM requests and create Access Reviews)
*   Azure AD P2 License (Required for PIM and Access Reviews functionality)

### Deployment

To deploy this project to your subscription, use the Azure CLI. Open a terminal and run the following command:

```bash
# 1. Login to Azure
az login

# 2. Set the variables for the deployment
PRINCIPAL_ID="<your-user-object-id>"
ALERT_EMAIL="<your-alert-email-address>"
LOCATION="eastus"

# 3. Deploy the Bicep template
az deployment sub create \
  --name "IdentityGovernanceDeployment" \
  --location "$LOCATION" \
  --template-file main.bicep \
  --parameters principalId="$PRINCIPAL_ID" alertEmailAddress="$ALERT_EMAIL"
```

## Structure
- `main.bicep`: Orchestrates the subscription-wide deployments, creating a Monitoring resource group and invoking the modules.
- `modules/rbac-pim.bicep`: Grants Contributor eligibility via PIM for 1 year.
- `modules/access-reviews.bicep`: Creates a quarterly review demanding justification for role retention.
- `modules/alerts.bicep`: Sets up Action Groups and the Privilege Escalation alert.
