(import :mosquitto/client)

(def (on-connect-callback client)
  (displayln (list 'on-connect-called client)))

(def client (make-mosquitto-client on-connect: on-connect-callback))
{client.connect! port: 1884}

(let loop ((n 10))
  {client.loop 1000}
  (when (> n 0)
    (loop (- n 1))))

(displayln 'main-loop-finished)
(thread-sleep! 1)
(##gc) ;; exec wills

(thread-sleep! 2)