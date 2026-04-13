targetScope = 'subscription'

@description('Display Name of the Access Review')
param reviewDisplayName string

@description('Principal ID of the Reviewer (User or Group that will conduct the review)')
param reviewerPrincipalId string

@description('A unique identifier for the Access Review definition')
param reviewId string = guid(subscription().id, reviewerPrincipalId, reviewDisplayName)

@description('Creates an Access Review Schedule')
resource accessReview 'Microsoft.Authorization/accessReviewScheduleDefinitions@2021-12-01-preview' = {
  name: reviewId
  properties: {
    displayName: reviewDisplayName
    descriptionForAdmins: 'Quarterly automated review to ensure least privilege is maintained'
    descriptionForReviewers: 'Please review and justify your assigned privileges.'
    reviewers: [
      {
        principalId: reviewerPrincipalId
        principalType: 'user' // We assume a user object for portfolio self-review. Adjust to 'group' if standardizing to an Admin group.
      }
    ]
    settings: {
      mailNotificationsEnabled: true
      reminderNotificationsEnabled: true
      justificationRequiredOnApproval: true
      autoApplyDecisionsEnabled: false
      recommendationsEnabled: true
      defaultDecisionEnabled: false
    }
  }
}

output accessReviewId string = accessReview.id
