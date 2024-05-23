(import :gerbil/gambit
        :std/test
        :std/logger
        :std/event
        :std/actor
        :std/sugar
        :std/format
        :std/misc/ports
        :std/misc/process
        :std/misc/func
        ./client)
(export client-test test-setup! test-cleanup!)

(deflogger client-test)
(current-logger-options 'info)

(def socket-path "./test/mosquitto.sock")
(def mosquitto-job (void))
(def mosquitto-pid (void))

(def mosquitto-config-path
  (or (get-environment-variable "MOSQUITTO_CONFIG_PATH")
      "test/mosquitto.conf"))

(def (start-mosquitto!)
  (if (file-exists? socket-path)
    (delete-file socket-path))
  (spawn (lambda ()
           (<- (query
                (let* ((settings [
                                  path: "mosquitto"
                                  arguments: ["-c" mosquitto-config-path]
                                  stdin-redirection: #f
                                  stdout-redirection: #f
                                  stderr-redirection: #f])
                       (process (open-process settings)))
                  (try
                   (when (eq? query 'pid)
                     (--> (process-pid process)))
                   (def result (read-all-as-string process))
                   (def status (process-status process))
                   (unless (zero? status)
                     (error (format "mosquitto exited with code ~a" status)))
                   result
                   (finally
                    (close-port process)
                    (process-status process)))))))))

(def (test-setup!)
  (start-logger!)
  (infof "using lib version ~a" mosquitto-lib-version)
  (set! mosquitto-job (start-mosquitto!))
  (infof "using mosquitto configuration path ~a" mosquitto-config-path)
  (set! mosquitto-pid (->> mosquitto-job 'pid))
  (infof "running mosquitto with pid ~a" mosquitto-pid))

(def (test-cleanup!)
  (run-process ["kill" "-SIGTERM" (number->string mosquitto-pid)])
  (sync (handle-evt 5
                    (lambda _
                      (error "mosquitto termination timeout")))
        mosquitto-job))

;;

(def client-test
  (test-suite "test client"
    (test-case "integration test"
      (def connected #f)
      (def messages 0)
      (def disconnected #f)
      (def (assert-loop-error exn)
        (check (any-of '((lost) (loop)) (error-irritants exn)) => #t))
      (def client
        (make-mosquitto-client
         on-connect: (lambda (client) (set! connected #t))
         on-message: (lambda (client message) (set! messages (+ 1 messages)))
         on-disconnect: (lambda (client) (set! disconnected #t))))
      (check (sync (handle-evt 1 void) mosquitto-job) => (void))
      {client.connect! socket: socket-path}
      (def job {client.spawn on-error: assert-loop-error})
      {client.subscribe! "test"}
      {client.publish! "test" (string->utf8 "halo")}
      {client.publish! "test" (string->utf8 "worl")}
      (sync (handle-evt 1 void) job)
      {client.disconnect!}
      (sync (handle-evt 1 void) job)
      (check connected => #t)
      (check disconnected => #t)
      (check messages => 2))))
