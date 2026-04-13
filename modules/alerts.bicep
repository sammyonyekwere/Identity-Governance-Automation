targetScope = 'resourceGroup'

@description('Email address to send alerts for privilege escalation')
param actionGroupEmail string

@description('Subscription ID for the scope of the alert')
param subscriptionId string

var actionGroupName = 'PrivilegeEscalationActionGroup'
var alertName = 'Privilege Escalation Role Assignment Alert'

@description('Creates an Action Group to send an email notification')
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: 'PrivEscAlert'
    enabled: true
    emailReceivers: [
      {
        name: 'AdminEmailReceiver'
        emailAddress: actionGroupEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

@description('Creates an Activity Log Alert for new Role Assignments')
resource roleAssignmentAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: alertName
  location: 'Global'
  properties: {
    description: 'Alert triggered when a new role assignment is written, potentially indicating a privilege escalation.'
    enabled: true
    scopes: [
      '/subscriptions/${subscriptionId}'
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Authorization/roleAssignments/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
        }
      ]
    }
  }
}
