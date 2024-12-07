;; exoplanet-discovery contract

(define-data-var next-discovery-id uint u0)

(define-map discoveries
  uint
  {
    discoverer: principal,
    name: (string-ascii 64),
    coordinates: (string-ascii 32),
    status: (string-ascii 20),
    reward: uint
  }
)

(define-constant reward-amount u1000)

(define-public (submit-discovery (name (string-ascii 64)) (coordinates (string-ascii 32)))
  (let
    (
      (discovery-id (var-get next-discovery-id))
    )
    (map-set discoveries discovery-id {
      discoverer: tx-sender,
      name: name,
      coordinates: coordinates,
      status: "pending",
      reward: u0
    })
    (var-set next-discovery-id (+ discovery-id u1))
    (ok discovery-id)
  )
)

(define-public (verify-discovery (discovery-id uint))
  (match (map-get? discoveries discovery-id)
    discovery (begin
      (map-set discoveries discovery-id
        (merge discovery {
          status: "verified",
          reward: reward-amount
        })
      )
      (ok true)
    )
    (err u404)
  )
)

(define-read-only (get-discovery (discovery-id uint))
  (map-get? discoveries discovery-id)
)

