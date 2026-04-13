targetScope = 'subscription'

@description('Principal ID of the user or group to be granted PIM eligibility')
param principalId string

@description('Object ID of the role to assign')
param roleDefinitionId string

@description('A unique identifier for the PIM assignment request. Defaults to a new GUID tied to the deployment.')
param requestName string = guid(subscription().id, principalId, roleDefinitionId)

var roleDefinitionResourceId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)

@description('Creates an eligible role assignment schedule request (PIM)')
resource pimEligibilityRequest 'Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview' = {
  name: requestName
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionResourceId
    requestType: 'AdminUpdate' // 'AdminUpdate' will grant/update eligibility for the principal
    justification: 'Automated Identity Governance PIM Eligibility Grant via Bicep Portfolio'
    scheduleInfo: {
      startDateTime: utcNow()
      expiration: {
        type: 'AfterDuration'
        endDateTime: null
        duration: 'P365D' // Eligibility lasts for 1 year
      }
    }
  }
}

output pimRequestId string = pimEligibilityRequest.name
