;; ArtProvenance - Digital art provenance and authenticity verification system
(define-map digital-artworks uint {
  artist: principal,
  artwork-title: (string-utf8 64),
  creation-details: (string-utf8 256),
  creation-timestamp: uint,
  medium-type: (string-utf8 64),
  authenticated: bool
})

(define-map artist-portfolio principal (list 100 uint))
(define-map art-curators principal bool)
(define-data-var artwork-id-generator uint u0)

;; Error codes
(define-constant err-unauthorized-artist (err u1000))
(define-constant err-unauthorized-curator (err u1001))
(define-constant err-artwork-not-found (err u1002))
(define-constant err-access-restricted (err u403))
(define-constant err-portfolio-capacity-exceeded (err u1004))
(define-constant err-invalid-curator-principal (err u1005))
(define-constant err-invalid-artwork-title (err u1006))
(define-constant err-invalid-creation-details (err u1007))
(define-constant err-invalid-creation-timestamp (err u1008))
(define-constant err-invalid-medium-type (err u1009))
(define-constant err-invalid-artwork-id (err u1010))

;; Gallery director for art authentication
(define-constant gallery-director tx-sender)

;; Register art curator
(define-public (register-art-curator (curator principal))
  (begin
    ;; Verify sender is gallery director
    (asserts! (is-eq tx-sender gallery-director) err-access-restricted)
    
    ;; Validate curator principal
    (asserts! (not (is-eq curator 'SP000000000000000000002Q6VF78)) err-invalid-curator-principal)
    
    ;; Add curator to registry
    (ok (map-set art-curators curator true))
  )
)

;; Register digital artwork
(define-public (register-digital-artwork 
  (artwork-title (string-utf8 64)) 
  (creation-details (string-utf8 256)) 
  (creation-timestamp uint) 
  (medium-type (string-utf8 64)))
  (let
    ((artwork-id (var-get artwork-id-generator))
     (artist tx-sender)
     (current-portfolio (default-to (list) (map-get? artist-portfolio artist))))
    
    ;; Validate input parameters
    (asserts! (> (len artwork-title) u0) err-invalid-artwork-title)
    (asserts! (> (len creation-details) u0) err-invalid-creation-details)
    (asserts! (> creation-timestamp u1600000000) err-invalid-creation-timestamp)
    (asserts! (> (len medium-type) u0) err-invalid-medium-type)
    
    ;; Check portfolio capacity
    (asserts! (< (len current-portfolio) u100) err-portfolio-capacity-exceeded)
    
    ;; Store artwork information
    (map-set digital-artworks artwork-id {
      artist: artist,
      artwork-title: artwork-title,
      creation-details: creation-details,
      creation-timestamp: creation-timestamp,
      medium-type: medium-type,
      authenticated: false
    })
    
    ;; Update artist portfolio
    (let 
      ((updated-portfolio (unwrap-panic (as-max-len? (concat (list artwork-id) current-portfolio) u100))))
      (map-set artist-portfolio artist updated-portfolio)
    )
    
    ;; Increment artwork ID generator
    (var-set artwork-id-generator (+ artwork-id u1))
    
    (ok artwork-id)))

;; Authenticate digital artwork
(define-public (authenticate-digital-artwork (artwork-id uint))
  (begin
    ;; Validate artwork ID
    (asserts! (< artwork-id (var-get artwork-id-generator)) err-invalid-artwork-id)
    
    (let
      ((artwork (unwrap! (map-get? digital-artworks artwork-id) err-artwork-not-found)))
      
      ;; Check if sender is authorized curator
      (asserts! (default-to false (map-get? art-curators tx-sender)) err-unauthorized-curator)
      
      ;; Update authentication status
      (ok (map-set digital-artworks artwork-id (merge artwork {authenticated: true})))
    )
  )
)

;; Get digital artwork details
(define-read-only (get-digital-artwork (artwork-id uint))
  (map-get? digital-artworks artwork-id))

;; Get artist portfolio
(define-read-only (get-artist-portfolio (artist principal))
  (default-to (list) (map-get? artist-portfolio artist)))

;; Check curator authorization
(define-read-only (is-art-curator (address principal))
  (default-to false (map-get? art-curators address)))