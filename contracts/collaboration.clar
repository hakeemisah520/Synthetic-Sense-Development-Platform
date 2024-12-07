;; collaboration contract

(define-map projects
  { project-id: uint }
  {
    owner: principal,
    collaborators: (list 10 principal),
    status: (string-ascii 20)
  }
)

(define-data-var last-project-id uint u0)

(define-public (create-project)
  (let
    (
      (project-id (+ (var-get last-project-id) u1))
    )
    (map-set projects
      { project-id: project-id }
      {
        owner: tx-sender,
        collaborators: (list tx-sender),
        status: "active"
      }
    )
    (var-set last-project-id project-id)
    (ok project-id)
  )
)

(define-public (add-collaborator (project-id uint) (collaborator principal))
  (let
    (
      (project (unwrap! (map-get? projects { project-id: project-id }) (err u404)))
    )
    (asserts! (is-eq (get owner project) tx-sender) (err u403))
    (asserts! (< (len (get collaborators project)) u10) (err u401))
    (ok (map-set projects
      { project-id: project-id }
      (merge project { collaborators: (unwrap! (as-max-len? (append (get collaborators project) collaborator) u10) (err u401)) })
    ))
  )
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
  (let
    (
      (project (unwrap! (map-get? projects { project-id: project-id }) (err u404)))
    )
    (asserts! (is-eq (get owner project) tx-sender) (err u403))
    (ok (map-set projects
      { project-id: project-id }
      (merge project { status: new-status })
    ))
  )
)

(define-read-only (get-project (project-id uint))
  (map-get? projects { project-id: project-id })
)

