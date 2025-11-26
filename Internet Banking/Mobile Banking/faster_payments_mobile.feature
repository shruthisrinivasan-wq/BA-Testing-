Feature: Faster Payments - Mobile Banking Single Immediate Domestic Transfer
  As a Retail Customer using the Mobile Banking app I want to send a single immediate domestic payment so that funds settle quickly, I get confirmation, and the bank enforces validation, compliance and security controls.

  # Happy Path
  Scenario: Successful Instant Transfer via Mobile Push / Biometric
    Given I am authenticated in the Mobile Banking app on the Accounts screen
    And I have selected a Source Account with Available Balance >= £250.00
    And I have entered a valid Payee with Payee Name, Sort Code and Account Number passing modulus checks
    And Confirmation of Payee (CoP) returns an Exact Match
    When I enter Amount £250.00 and a valid Payment Reference and tap Confirm Payment
    And I approve the mobile push notification or authenticate with biometric on my device
    Then the system debits the Source Account ledger immediately
    And the system sends the payment to the Faster Payments Gateway
    And the Gateway returns Success
    And the app displays "Payment Sent. Transaction ID: <id>" within 5 seconds of completing SCA
    And an immutable audit record is written for the payment and SCA event

  # Validation & Business Rules
  Scenario: Reject Payment When Insufficient Available Balance
    Given my Source Account Available Balance is £20.00
    When I attempt to send Amount £100.00
    Then the system blocks submission and displays "Insufficient available balance"
    And no ledger debit or external message is sent
    And the attempt is logged in the audit trail

  Scenario: Field Validation - Invalid Sort Code or Account Number
    Given I enter a Sort Code or Account Number that fails modulus validation
    When I attempt to proceed
    Then the app displays field-level validation errors and prevents submission

  Scenario: Field Validation - Invalid Payment Reference
    Given I enter a Payment Reference with disallowed special characters or exceeding 18 characters
    When I attempt to submit
    Then the app displays a validation error and prevents submission

  # Regulatory & Compliance
  Scenario: Confirmation of Payee - Partial Match Warning
    Given CoP returns a Close Match for the payee name
    When I view the Review screen
    Then the app shows a warning "Name matches partially" and highlights differences
    And the user may correct details or proceed after explicit acknowledgement

  Scenario: Confirmation of Payee - No Match Requires Acknowledgement
    Given CoP returns No Match for the provided payee details
    When I attempt to proceed without acknowledging the risk
    Then the app prevents submission and prompts for explicit acknowledgement
    When I explicitly acknowledge and confirm
    Then the payment proceeds and the CoP failure and acknowledgement are recorded in the audit trail

  Scenario: AML Flagging Causes Pending Status
    Given I submit a payment that triggers an AML/fraud rule
    When the asynchronous AML check flags the transaction
    Then the system marks the payment as Pending Review and shows the app message "Pending — under review"
    And ledger update is recorded and case is created for compliance review

  # Security & Authentication
  Scenario: SCA Failure (Biometric/Push/OTP) Prevents Payment
    Given I have initiated the payment and the mobile app issued an SCA challenge
    When I fail to approve the push, biometric fails, or I enter an incorrect OTP
    Then the payment is not sent to the Faster Payments Gateway
    And the app displays "Authentication failed — payment not completed"
    And the failed attempt is logged

  Scenario: Device Not Registered for Push Fallback to SMS
    Given my device is not registered to receive push notifications
    When I attempt to make a payment
    Then the app falls back to SMS OTP SCA and prompts the user accordingly

  Scenario: Session Timeout on Mobile Payment Screen
    Given I take more than 5 minutes on the payment screen
    When the timeout triggers
    Then the app clears sensitive inputs, cancels the flow, and requires re-authentication

  Scenario: Unauthorized Access Attempt
    Given a user who is not fully authenticated attempts to access the Make a Payment flow
    When they navigate to the payment functionality
    Then access is denied and the attempt is recorded in the security audit log

  # Edge Cases & Resilience
  Scenario: Network Loss During Payment After Ledger Debit
    Given I submitted a payment and the ledger was debited
    And the app loses network connectivity before gateway response is received
    When the gateway status cannot be confirmed immediately
    Then the system marks the payment as Pending and shows "Payment submitted — status pending" in the app
    And asynchronous retry/reconciliation will occur
    And all actions are recorded in the audit trail

  Scenario: Concurrent Mobile Payments Causing Conflict
    Given I initiate two near-simultaneous payments from the same account with combined amount exceeding Available Balance
    When both requests are processed concurrently
    Then atomic ledger checks allow only one to succeed and the other is rejected with "Insufficient available balance"
    And both outcomes are logged

  Scenario: Faster Payments Gateway Rejects With Business Code
    Given the gateway returns a reject code for business reasons
    When the gateway response is Reject
    Then the app displays a user-friendly failure message and support return code
    And ledger and transaction state are reconciled per reject-handling rules and the event recorded
