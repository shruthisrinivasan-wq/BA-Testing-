**User Story:**
As a Retail Customer using the Mobile Banking app, I want to initiate a single immediate domestic transfer to a specified beneficiary from my Accounts screen, So that funds settle to the beneficiary within seconds and I receive an immediate confirmation and receipt.

Context:
- Channel: Mobile Banking (iOS/Android)
- Source: Accounts screen -> Make a Payment
- Scope: Single immediate domestic transfers (New or Saved Payee), Confirmation of Payee (CoP), Strong Customer Authentication (push/biometric/SMS), immediate ledger update and message to Faster Payments Gateway.

Notes:
- Required fields: Payee Name (max 35 chars), Sort Code (6 digits, modulus check), Account Number (8 digits, modulus check), Payment Reference (max 18 chars, no special chars), Amount (£0.01 - £10,000 daily cap).
- SCA methods: mobile app push approval, biometric approval on device, or SMS OTP fallback.
- Session Timeout: payment screen must timeout after 5 minutes of inactivity.
- Performance: UI must show final Success/Failure within 5 seconds after 2FA is completed.
- Compliance: KYC/CoP checks, AML asynchronous checks, immutable audit trail.
