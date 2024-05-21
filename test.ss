(import :std/event
        :mosquitto/client)

(def (on-connect-callback client)
  (displayln (list 'on-connect-called client)))

(def (on-message-callback client message)
  (displayln (list 'on-message-called client message (utf8->string (mosquitto-message-payload message)))))

(def client (make-mosquitto-client
             on-connect: on-connect-callback
             on-message: on-message-callback))
{client.connect! port: 1884}

(def job (spawn
          (lambda ()
            (let loop ()
              {client.loop 10}
              (thread-yield!)
              (loop)))))
{client.subscribe! "test"}
(spawn (lambda ()
         (thread-sleep! 1)
         {client.publish! "test" (string->utf8 "halo")}))
(wait job)

(displayln 'main-loop-finished)
(thread-sleep! 1)
(##gc) ;; exec wills

(thread-sleep! 2)