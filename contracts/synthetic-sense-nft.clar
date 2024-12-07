;; synthetic-sense-nft contract

(define-non-fungible-token synthetic-sense uint)

(define-data-var last-token-id uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-public (mint (sense-uri (string-utf8 256)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? synthetic-sense token-id tx-sender))
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (nft-transfer? synthetic-sense token-id sender recipient)
  )
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? synthetic-sense token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok "https://api.example.com/synthetic-sense/")
)
