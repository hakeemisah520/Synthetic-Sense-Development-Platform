;; peer-review contract

(define-data-var next-review-id uint u0)

(define-map reviews
  uint
  {
    reviewer: principal,
    discovery-id: uint,
    rating: uint,
    comment: (string-utf8 256),
    status: (string-ascii 20)
  }
)

(define-public (submit-review (discovery-id uint) (rating uint) (comment (string-utf8 256)))
  (let
    (
      (review-id (var-get next-review-id))
    )
    (asserts! (< rating u6) (err u400)) ;; Rating must be between 0 and 5
    (map-set reviews review-id {
      reviewer: tx-sender,
      discovery-id: discovery-id,
      rating: rating,
      comment: comment,
      status: "submitted"
    })
    (var-set next-review-id (+ review-id u1))
    (ok review-id)
  )
)

(define-public (approve-review (review-id uint))
  (match (map-get? reviews review-id)
    review (begin
      (map-set reviews review-id
        (merge review { status: "approved" })
      )
      (ok true)
    )
    (err u404)
  )
)

(define-read-only (get-review (review-id uint))
  (map-get? reviews review-id)
)

