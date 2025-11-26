**User Story:**
As a Retail Customer, I want to initiate a single immediate domestic transfer to a specified beneficiary from my Accounts dashboard, So that funds are settled to the beneficiary within seconds and I receive a transaction receipt and confirmation.

Context:
- Source: Accounts dashboard (Make a Payment)
- Scope: Single immediate domestic transfers (New or Saved Payee), Confirmation of Payee (CoP) checks, Strong Customer Authentication (2FA), immediate ledger update and message to Faster Payments Gateway.

Notes:
- Required fields: Payee Name (max 35 chars), Sort Code (6 digits, modulus check), Account Number (8 digits, modulus check), Payment Reference (max 18 chars, no special chars), Amount (£0.01 - £10,000 daily cap).
- Performance: UI must display result within 5 seconds of the user entering their 2FA code.
- Compliance: KYC/CoP, AML asynchronous checks for flagged transactions, audit trail logging.
