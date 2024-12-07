;; neuroplasticity-training contract

(define-map training-programs
  { program-id: uint }
  {
    creator: principal,
    name: (string-ascii 64),
    description: (string-utf8 256),
    duration: uint
  }
)

(define-map user-progress
  { user: principal, program-id: uint }
  {
    completed-sessions: uint,
    last-session: uint
  }
)

(define-data-var last-program-id uint u0)

(define-public (create-program (name (string-ascii 64)) (description (string-utf8 256)) (duration uint))
  (let
    (
      (program-id (+ (var-get last-program-id) u1))
    )
    (map-set training-programs
      { program-id: program-id }
      {
        creator: tx-sender,
        name: name,
        description: description,
        duration: duration
      }
    )
    (var-set last-program-id program-id)
    (ok program-id)
  )
)

(define-public (record-training-session (program-id uint))
  (let
    (
      (program (unwrap! (map-get? training-programs { program-id: program-id }) (err u404)))
      (progress (default-to { completed-sessions: u0, last-session: u0 }
        (map-get? user-progress { user: tx-sender, program-id: program-id })))
    )
    (asserts! (> block-height (+ (get last-session progress) u144)) (err u401))
    (map-set user-progress
      { user: tx-sender, program-id: program-id }
      {
        completed-sessions: (+ (get completed-sessions progress) u1),
        last-session: block-height
      }
    )
    (ok true)
  )
)

(define-read-only (get-program (program-id uint))
  (map-get? training-programs { program-id: program-id })
)

(define-read-only (get-user-progress (user principal) (program-id uint))
  (map-get? user-progress { user: user, program-id: program-id })
)

