(import :gerbil/gambit
        :std/test
        :std/logger
        :std/event
        :std/sugar
        :std/iter
        :std/format
        :std/hash-table
        :std/misc/ports
        :std/misc/process
        :std/misc/completion
        :std/misc/func
        ./client)
(export client-test test-setup! test-cleanup!)

;; MOSQUITTO_CONFIG_PATH - if presented should contain path to mosquitto config (keep in mind hardcoded `socket-path` & `pid-path`)
;; MOSQUITTO_NOSTART - if presented (value don't matter) it is expected mosquitto was started using `make mosquitto`

(deflogger client-test)
(current-logger-options 'info)

;;

(def start-mosquitto? (if (get-environment-variable "MOSQUITTO_NOSTART") #f #t))
(def socket-path "./test/mosquitto.sock")
(def pid-path "./test/mosquitto.pid")
(def mosquitto-config-path
  (or (get-environment-variable "MOSQUITTO_CONFIG_PATH")
      "test/mosquitto.conf"))
(def mosquitto-job (void))

;;

(def (start-mosquitto!)
  (for (path [socket-path pid-path])
    (if (file-exists? path)
      (delete-file path)))
  (begin0 (spawn (lambda ()
                   (run-process/batch
                    ["mosquitto" "-c" mosquitto-config-path])))
    (sync (handle-evt 5 (lambda () (error "timed out waiting for mosquitto to start")))
          (spawn (lambda ()
                   (let lp ()
                     (unless (file-exists? pid-path)
                       (thread-sleep! 0.01)
                       (lp))))))))

(def (test-setup!)
  (start-logger!)
  (infof "using lib version ~a" mosquitto-lib-version)
  (when start-mosquitto?
    (set! mosquitto-job (start-mosquitto!)))
  (infof "using mosquitto configuration path ~a" mosquitto-config-path)
  (infof "running mosquitto with pid ~a" (read-file-string pid-path)))

(def (test-cleanup!)
  (when start-mosquitto?
    (run-process ["kill" "-SIGTERM" (read-file-string pid-path)])
    (sync mosquitto-job
          (handle-evt 15 (lambda ()
                           (error "timed out waiting for mosquitto to exit"))))))

;;

(def client-test
  (test-suite "test client"
    (test-case "integration test"
      (def timeout 60)

      (def connected? (void))
      (def subscribed? (void))
      (def messaged? (void))
      (def disconnected? (void))

      (def (setup-completions!)
        (set! connected? (make-completion 'connected))
        (set! subscribed? (make-completion 'subscribed))
        (set! messaged? (make-completion 'message))
        (set! disconnected? (make-completion 'disconnected))
        (def threads (make-hash-table))
        (for (completion [connected? subscribed? messaged? disconnected?])
          (hash-put! threads
                     completion
                     (spawn (lambda ()
                              (thread-sleep! timeout)
                              (completion-error! completion "timedout"))))
          ;; cancelation of delayed deadlines
          (make-will completion
                     (lambda (completion)
                       (thread-terminate! (hash-ref threads completion)))))
        (thread-yield!))

      (def client
        (make-mosquitto-client
         on-connect: (lambda (client exn)
                       (if exn (completion-error! connected? exn)
                           (completion-post! connected? 'done)))
         on-subscribe: (lambda (client mid)
                         (completion-post! subscribed? mid))
         on-message: (lambda (client message)
                       (let (payload (mosquitto-message-payload message))
                         (completion-post! messaged? (if (void? payload) payload (utf8->string payload)))))
         on-disconnect: (lambda (client exn)
                          (if exn (completion-error! disconnected? exn)
                              (completion-post! disconnected? 'done)))))

      (def loop {client.loop!})

      (try
       (test-case "sub-pub"
         (setup-completions!)
         {client.connect! socket: socket-path}
         (check (completion-wait! connected?) => 'done)
         (infof "connected")
         {client.subscribe! "test"}
         (check (> (completion-wait! subscribed?) 0) => #t)
         (infof "subscribed")
         {client.publish! "test" (string->utf8 "hello")}
         (check (completion-wait! messaged?) => "hello")
         (infof "sent & received messages")
         {client.disconnect!}
         (check (completion-wait! disconnected?) => 'done)
         (infof "disconnected"))
       (test-case "reconnect"
         (setup-completions!)
         {client.reconnect!}
         (check (completion-wait! connected?) => 'done)
         (infof "reconnected")
         {client.disconnect!}
         (check (completion-wait! disconnected?) => 'done)
         (infof "disconnected"))
       (test-case "will"
         (setup-completions!)
         {client.will! "will-test" (string->utf8 "here is the will")}
         {client.reconnect!}
         (check (completion-wait! connected?) => 'done)
         (infof "reconnected")
         (def sub-connected? (make-completion 'sub-connected))
         (def sub-subscribed? (make-completion 'sub-subscribed))
         (def will-triggered? (make-completion 'will-triggered))
         (def sub-client
           (make-mosquitto-client
            on-connect: (lambda (client exn)
                          (if exn (completion-error! connected? exn)
                              (completion-post! sub-connected? 'done)))
            on-subscribe: (lambda (client mid)
                            (completion-post! sub-subscribed? 'done))
            on-message: (lambda (client message)
                          (let (payload (mosquitto-message-payload message))
                            (completion-post! will-triggered? (utf8->string payload))))))
         (def sub-loop {sub-client.loop!})
         {sub-client.connect! socket: socket-path}
         (check (completion-wait! sub-connected?) => 'done)
         {sub-client.subscribe! "will-test"}
         (check (completion-wait! sub-subscribed?) => 'done)
         (infof "simulating ungraceful shutdown")
         (thread-terminate! loop)
         (check (completion-wait! will-triggered?) => "here is the will")
         {sub-client.disconnect!}
         (thread-terminate! sub-loop))
       (finally (thread-terminate! loop)
                (check (thread-state-running? loop) => #f))))))
