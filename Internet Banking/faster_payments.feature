Feature: Faster Payments - Single Immediate Domestic Transfer
  As a Retail Customer I want to send a single immediate domestic payment to a beneficiary so that funds settle quickly, I receive a confirmation, and the bank enforces validation, compliance and security controls.

  # Scenario 1: Happy Path
  Scenario: Successful Instant Transfer
    Given I am an authenticated Retail Customer on the Accounts dashboard
    And I have selected a Source Account with Available Balance >= £500.00
    And I have chosen a Payee (New or Saved) with valid Payee Name, Sort Code and Account Number
    And Confirmation of Payee (CoP) returns an Exact Match
    When I enter Amount £500.00 and a valid Payment Reference and click Confirm Payment
    And I complete Strong Customer Authentication by approving the push notification or entering the SMS OTP
    Then the system deducts the funds from the Source Account ledger immediately
    And the system sends the payment message to the Faster Payments Gateway (ISO 8583/20022)
    And the Gateway returns Success
    And the UI displays "Payment Sent. Transaction ID: <id>" within 5 seconds of entering the 2FA
    And an immutable audit record is written for the payment attempt and outcome

  # Scenario 2: Validation & Business Rule - Insufficient Funds
  Scenario: Payment Rejected When Available Balance Is Insufficient
    Given I am authenticated and on the payment screen
    And my Source Account Available Balance is £49.00
    When I attempt to send Amount £100.00
    Then the system performs a Balance Check and rejects the submission
    And the UI displays a clear error "Insufficient available balance"
    And no ledger debit or Faster Payments message is sent
    And the attempt is logged in the audit trail

  Scenario: Validation Failure - Invalid Sort Code or Account Number
    Given I enter a Sort Code or Account Number that fails modulus validation
    When I attempt to proceed from the payment input screen
    Then the UI blocks submission and displays field-level validation messages describing the error
    And the invalid input is not sent to external systems

  Scenario: Validation Failure - Invalid Payment Reference
    Given I enter a Payment Reference containing disallowed special characters or over 18 characters
    When I attempt to submit
    Then the UI displays a validation error and prevents submission

  # Scenario 3: Regulatory & Compliance
  Scenario: Confirmation of Payee - Partial (Close) Match
    Given I have entered payee account details and the CoP service returns a Close Match
    When I review the payment on the Review Screen
    Then the UI displays a prominent warning "Name matches partially" and highlights the discrepancy
    And the user may either correct details or choose to continue after explicit acknowledgement

  Scenario: Confirmation of Payee - No Match Requires Acknowledgement
    Given CoP returns No Match for the provided name/account
    When I try to proceed without acknowledging the risk
    Then the UI prevents submission and prompts the user to acknowledge the risk in a clear checkbox/dialog
    When I explicitly acknowledge the risk and confirm payment
    Then the system proceeds but records the CoP failure and the user acknowledgement in the audit trail

  Scenario: AML Flagging Triggers Pending Review
    Given I submit a payment with an Amount or pattern that triggers an AML/fraud rule
    When the asynchronous AML check flags the transaction
    Then the system marks the payment as Pending Review and does not present a final Success
    And the ledger entry is recorded and the user sees "Pending — under review"
    And the event is logged for compliance and case management

  # Scenario 4: Security & Authentication
  Scenario: 2FA Failure or Rejection
    Given I have initiated the payment and the system issued a 2FA challenge
    When I fail to approve the push or enter an incorrect OTP
    Then the payment is not sent to the Faster Payments Gateway
    And the UI displays "Authentication failed — payment not completed"
    And the failed attempt is logged in the audit trail

  Scenario: Session Timeout During Payment Flow
    Given I am on the payment screen and take more than 5 minutes to complete entry
    When the session timeout triggers
    Then the user is signed out or the flow is cancelled and sensitive input is cleared
    And the UI prompts the user to re-authenticate and restart the payment

  Scenario: Unauthorized Access Attempt
    Given a user without sufficient privileges or not fully authenticated attempts to access the payment flow
    When they navigate to the Make a Payment function
    Then access is denied and a generic error/redirect is shown
    And the attempt is recorded in the security audit log

  # Scenario 5: Edge Cases & Resilience
  Scenario: Gateway Timeout / Network Failure After Ledger Debit
    Given I submitted a payment and the system has updated the ledger (debit)
    And the connection to the Faster Payments Gateway times out or fails
    When the gateway status cannot be confirmed within the timeout window
    Then the system marks the payment as Pending and shows the user "Payment submitted — status pending"
    And retries or reconciliation logic will proceed asynchronously
    And all actions are recorded in the audit trail

  Scenario: Concurrent Transactions Leading To Conflict
    Given I initiate two near-simultaneous payments from the same Source Account with a combined amount exceeding Available Balance
    When both payment requests are processed concurrently
    Then the system applies atomic ledger checks and allows only one payment to succeed
    And the other payment is rejected with "Insufficient available balance"
    And both outcomes are logged

  Scenario: Faster Payments Gateway Rejection Codes
    Given the Faster Payments Gateway returns a Reject code for business reasons
    When the gateway response is Reject
    Then the system displays a user-friendly failure reason and a return code for support
    And the ledger and transaction state are reconciled according to the reject handling rules and the audit trail records the response
