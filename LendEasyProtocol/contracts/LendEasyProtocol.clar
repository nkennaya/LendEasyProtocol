;; LendEasyProtocol
;; A decentralized lending protocol allowing borrowers to request loans and lenders to fund them

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant PENALTY_RATE u100)  ;; 1% penalty rate
(define-constant MIN_COLLATERAL_RATIO u150)  ;; 150% minimum collateral ratio
(define-constant INTEREST_DENOMINATOR u10000)

;; Data Variables
(define-data-var total-loans uint u0)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u102))
(define-constant ERR-LOAN-NOT-FOUND (err u103))
(define-constant ERR-ALREADY-FUNDED (err u104))
(define-constant ERR-OVERDUE (err u105))

;; Principal Maps
(define-map loans
    { loan-id: uint }
    {
        borrower: principal,
        lender: (optional principal),
        amount: uint,
        collateral: uint,
        interest-rate: uint,
        due-height: uint,
        status: (string-ascii 20),
        paid-amount: uint
    }
)

(define-map borrower-positions
    { borrower: principal }
    { active-loans: uint }
)

;; Private Functions
(define-private (validate-collateral (amount uint) (collateral uint))
    (let (
        (required-collateral (/ (* amount MIN_COLLATERAL_RATIO) u100))
    )
    (>= collateral required-collateral))
)

(define-private (calculate-interest (principal uint) (rate uint) (blocks uint))
    (/ (* (* principal rate) blocks) INTEREST_DENOMINATOR)
)

(define-private (is-overdue (due-height uint))
    (> block-height due-height)
)

;; Public Functions
(define-public (request-loan (amount uint) (collateral uint) (interest-rate uint) (duration uint))
    (let (
        (loan-id (var-get total-loans))
        (borrower tx-sender)
    )
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (validate-collateral amount collateral) ERR-INSUFFICIENT-COLLATERAL)
        
        (try! (stx-transfer? collateral borrower (as-contract tx-sender)))
        
        (map-set loans
            { loan-id: loan-id }
            {
                borrower: borrower,
                lender: none,
                amount: amount,
                collateral: collateral,
                interest-rate: interest-rate,
                due-height: (+ block-height duration),
                status: "REQUESTED",
                paid-amount: u0
            }
        )
        
        (var-set total-loans (+ loan-id u1))
        (ok loan-id)
    )
)

(define-public (fund-loan (loan-id uint))
    (let (
        (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
        (lender tx-sender)
    )
        (asserts! (is-none (get lender loan)) ERR-ALREADY-FUNDED)
        (try! (stx-transfer? (get amount loan) lender (as-contract tx-sender)))
        
        (map-set loans
            { loan-id: loan-id }
            (merge loan {
                lender: (some lender),
                status: "ACTIVE"
            })
        )
        (ok true)
    )
)

(define-public (repay-loan (loan-id uint) (payment uint))
    (let (
        (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
        (borrower tx-sender)
    )
        (asserts! (is-eq borrower (get borrower loan)) ERR-NOT-AUTHORIZED)
        
        (let (
            (total-due (+ (get amount loan) 
                (calculate-interest 
                    (get amount loan) 
                    (get interest-rate loan) 
                    (- block-height (get due-height loan))
                )
            ))
            (new-paid-amount (+ payment (get paid-amount loan)))
        )
            (try! (stx-transfer? payment borrower (as-contract tx-sender)))
            
            (if (>= new-paid-amount total-due)
                (begin
                    ;; Loan fully repaid
                    (try! (stx-transfer? (get collateral loan) (as-contract tx-sender) borrower))
                    (map-set loans
                        { loan-id: loan-id }
                        (merge loan {
                            status: "REPAID",
                            paid-amount: new-paid-amount
                        })
                    )
                )
                ;; Partial payment
                (map-set loans
                    { loan-id: loan-id }
                    (merge loan {
                        paid-amount: new-paid-amount
                    })
                )
            )
            (ok true)
        )
    )
)

(define-public (liquidate-loan (loan-id uint))
    (let (
        (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
    )
        (asserts! (is-overdue (get due-height loan)) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get status loan) "ACTIVE") ERR-NOT-AUTHORIZED)
        
        ;; Transfer collateral to lender
        (try! (stx-transfer? 
            (get collateral loan) 
            (as-contract tx-sender) 
            (unwrap! (get lender loan) ERR-NOT-AUTHORIZED)
        ))
        
        (map-set loans
            { loan-id: loan-id }
            (merge loan {
                status: "LIQUIDATED"
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-loan (loan-id uint))
    (map-get? loans { loan-id: loan-id })
)

(define-read-only (get-borrower-loans (borrower principal))
    (map-get? borrower-positions { borrower: borrower })
)