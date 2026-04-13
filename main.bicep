targetScope = 'subscription'

@description('Principal ID of the user or group to be granted PIM eligibility for the role.')
param principalId string

@description('Role definition ID to assign (Default is Contributor: b24988ac-6180-42a0-ab88-20f7382dd24c)')
param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Email address to receive privilege escalation alerts.')
param alertEmailAddress string

@description('Location for the monitoring resources (Action Group and Alerts).')
param location string = deployment().location

@description('Name of the resource group to deploy monitoring resources to.')
param monitoringRgName string = 'rg-identity-governance'

// 1. Module: PIM Role Automation
module pim 'modules/rbac-pim.bicep' = {
  name: 'pim-deployment'
  params: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
  }
}

// 2. Module: Access Reviews
module accessReview 'modules/access-reviews.bicep' = {
  name: 'access-reviews-deployment'
  params: {
    reviewDisplayName: 'Quarterly Privileged Access Review'
    reviewerPrincipalId: principalId // Set up for self-review for portfolio/demo purposes
  }
}

// 3. Module: Privilege Escalation Alerts
// Note: Action Groups and Activity Log Alerts are grouped within a Resource Group.
resource monitoringRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: monitoringRgName
  location: location
}

module alerts 'modules/alerts.bicep' = {
  name: 'alerts-deployment'
  scope: monitoringRg
  params: {
    actionGroupEmail: alertEmailAddress
    subscriptionId: subscription().subscriptionId
  }
}
