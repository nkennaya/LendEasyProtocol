# LendEasyProtocol

LendEasyProtocol is a decentralized lending protocol that enables borrowers to request loans and lenders to fund them securely on the blockchain. The protocol ensures fair lending terms, collateralized borrowing, and automatic liquidations in case of overdue payments.

## Features
- **Decentralized Lending:** Borrowers can request loans, and lenders can fund them without intermediaries.
- **Collateralized Borrowing:** Ensures a minimum collateral ratio of 150% to secure loans.
- **Automated Liquidation:** Loans overdue beyond the due block height are liquidated automatically.
- **Interest Calculation:** Interest is calculated based on the agreed rate and loan duration.
- **Smart Contract Enforcement:** Ensures safe and transparent transactions using smart contracts.

## Constants
- **CONTRACT_OWNER:** The owner of the contract.
- **PENALTY_RATE:** 1% penalty rate for overdue loans.
- **MIN_COLLATERAL_RATIO:** 150% minimum collateral ratio.
- **INTEREST_DENOMINATOR:** Used for precise interest calculations.

## Data Variables
- **total-loans:** Keeps track of the number of loans issued.

## Error Codes
- **ERR-NOT-AUTHORIZED (100):** Action not authorized.
- **ERR-INVALID-AMOUNT (101):** Invalid loan amount.
- **ERR-INSUFFICIENT-COLLATERAL (102):** Collateral provided is insufficient.
- **ERR-LOAN-NOT-FOUND (103):** Loan does not exist.
- **ERR-ALREADY-FUNDED (104):** Loan is already funded.
- **ERR-OVERDUE (105):** Loan is overdue.

## Principal Maps
- **loans:** Stores loan details including borrower, lender, amount, collateral, interest rate, due height, status, and payments.
- **borrower-positions:** Tracks active loans for each borrower.

## Functions
### Private Functions
- **validate-collateral(amount, collateral):** Ensures sufficient collateral for a loan.
- **calculate-interest(principal, rate, blocks):** Computes interest on the loan.
- **is-overdue(due-height):** Checks if a loan is overdue.

### Public Functions
- **request-loan(amount, collateral, interest-rate, duration):** Borrowers request a loan.
- **fund-loan(loan-id):** Lenders fund an available loan.
- **repay-loan(loan-id, payment):** Borrowers repay loans.
- **liquidate-loan(loan-id):** Lenders liquidate overdue loans.

### Read-only Functions
- **get-loan(loan-id):** Retrieves loan details.
- **get-borrower-loans(borrower):** Retrieves a borrower’s active loans.

## How It Works
1. **Borrowers Request Loans**
   - Borrowers specify loan amount, collateral, interest rate, and duration.
   - Collateral is transferred to the smart contract.
2. **Lenders Fund Loans**
   - Lenders select and fund loans.
   - Loans transition from "REQUESTED" to "ACTIVE".
3. **Borrowers Repay Loans**
   - Payments include principal and interest.
   - Loans are marked "REPAID" upon full payment.
4. **Loan Liquidation**
   - If overdue, lenders can claim collateral.
   - Loans are marked "LIQUIDATED".

## Security Considerations
- **Collateralization:** Ensures borrowers deposit sufficient collateral.
- **Smart Contract Transfers:** Secure and automated fund handling.
- **Loan Tracking:** Prevents fraud and unauthorized modifications.

## License
LendEasyProtocol is released under an open-source license. Use at your own risk.

---
For further inquiries, reach out to the development team or open an issue in the repository.