;; telescope-allocation contract

(define-data-var next-allocation-id uint u0)

(define-map allocations
  uint
  {
    researcher: principal,
    telescope-id: uint,
    start-time: uint,
    duration: uint,
    status: (string-ascii 20)
  }
)

(define-public (request-allocation (telescope-id uint) (start-time uint) (duration uint))
  (let
    (
      (allocation-id (var-get next-allocation-id))
    )
    (map-set allocations allocation-id {
      researcher: tx-sender,
      telescope-id: telescope-id,
      start-time: start-time,
      duration: duration,
      status: "pending"
    })
    (var-set next-allocation-id (+ allocation-id u1))
    (ok allocation-id)
  )
)

(define-public (approve-allocation (allocation-id uint))
  (match (map-get? allocations allocation-id)
    allocation (begin
      (map-set allocations allocation-id
        (merge allocation { status: "approved" })
      )
      (ok true)
    )
    (err u404)
  )
)

(define-read-only (get-allocation (allocation-id uint))
  (map-get? allocations allocation-id)
)

