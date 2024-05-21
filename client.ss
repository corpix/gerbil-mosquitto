(import :std/foreign)
(export make-mosquitto-client
        mosquitto-clients
        mosquitto-client
        mosquitto-client?
        mosquitto-client-ptr
        mosquitto-client-user-data
        mosquitto-client-on-connect
        mosquitto-client-on-disconnect
        mosquitto-client-on-publish
        mosquitto-client-on-message
        mosquitto-client-on-subscribe
        mosquitto-client-on-unsubscribe
        mosquitto-client-on-log
        mosquitto-message
        mosquitto-message?
        mosquitto-message-id
        mosquitto-message-topic
        mosquitto-message-payload
        mosquitto-message-qos
        mosquitto-message-retain
        ;; mosquitto-connect
        ;; mosquitto-reinitialise
        ;; mosquitto-disconnect
        ;; mosquitto-loop-forever
        ;; mosquitto-loop
        ;; mosquitto-publish
        ;; mosquitto-subscribe
        ;; mosquitto-unsubscribe
        ;; mosquitto-mosquitto-lib-version
        )

(begin-ffi (mosquitto-client-ptr
            mosquitto-client-on-connect
            mosquitto-clients

            mosquitto*
            mosquitto_message*
            mosquitto_opt
            MOSQ_LOG_INFO
            MOSQ_LOG_NOTICE
            MOSQ_LOG_WARNING
            MOSQ_LOG_ERR
            MOSQ_LOG_DEBUG
            MOSQ_ERR_SUCCESS
            MOSQ_ERR_AUTH_CONTINUE
            MOSQ_ERR_NO_SUBSCRIBERS
            MOSQ_ERR_SUB_EXISTS
            MOSQ_ERR_CONN_PENDING
            MOSQ_ERR_NOMEM
            MOSQ_ERR_PROTOCOL
            MOSQ_ERR_INVAL
            MOSQ_ERR_NO_CONN
            MOSQ_ERR_CONN_REFUSED
            MOSQ_ERR_NOT_FOUND
            MOSQ_ERR_CONN_LOST
            MOSQ_ERR_TLS
            MOSQ_ERR_PAYLOAD_SIZE
            MOSQ_ERR_NOT_SUPPORTED
            MOSQ_ERR_AUTH
            MOSQ_ERR_ACL_DENIED
            MOSQ_ERR_UNKNOWN
            MOSQ_ERR_ERRNO
            MOSQ_ERR_EAI
            MOSQ_ERR_PROXY
            MOSQ_ERR_PLUGIN_DEFER
            MOSQ_ERR_MALFORMED_UTF8
            MOSQ_ERR_KEEPALIVE
            MOSQ_ERR_LOOKUP
            MOSQ_ERR_MALFORMED_PACKET
            MOSQ_ERR_DUPLICATE_PROPERTY
            MOSQ_ERR_TLS_HANDSHAKE
            MOSQ_ERR_QOS_NOT_SUPPORTED
            MOSQ_ERR_OVERSIZE_PACKET
            MOSQ_ERR_OCSP
            MOSQ_ERR_TIMEOUT
            MOSQ_ERR_RETAIN_NOT_SUPPORTED
            MOSQ_ERR_TOPIC_ALIAS_INVALID
            MOSQ_ERR_ADMINISTRATIVE_ACTION
            MOSQ_ERR_ALREADY_EXISTS

            CONNACK_ACCEPTED
            CONNACK_REFUSED_PROTOCOL_VERSION
            CONNACK_REFUSED_IDENTIFIER_REJECTED
            CONNACK_REFUSED_SERVER_UNAVAILABLE
            CONNACK_REFUSED_BAD_USERNAME_PASSWORD
            CONNACK_REFUSED_NOT_AUTHORIZED

            MOSQ_OPT_PROTOCOL_VERSION
            MOSQ_OPT_SSL_CTX
            MOSQ_OPT_SSL_CTX_WITH_DEFAULTS
            MOSQ_OPT_RECEIVE_MAXIMUM
            MOSQ_OPT_SEND_MAXIMUM
            MOSQ_OPT_TLS_KEYFORM
            MOSQ_OPT_TLS_ENGINE
            MOSQ_OPT_TLS_ENGINE_KPASS_SHA1
            MOSQ_OPT_TLS_OCSP_REQUIRED
            MOSQ_OPT_TLS_ALPN
            MOSQ_OPT_TCP_NODELAY
            MOSQ_OPT_BIND_ADDRESS
            MOSQ_OPT_TLS_USE_OS_CERTS

            mosquitto_new
            mosquitto_destroy
            mosquitto_lib_version
            mosquitto_reinitialise
            mosquitto_will_set
            mosquitto_will_clear
            mosquitto_username_pw_set
            mosquitto_connect
            mosquitto_connect_bind
            mosquitto_connect_async
            mosquitto_connect_bind_async
            mosquitto_disconnect
            mosquitto_reconnect
            mosquitto_reconnect_async
            mosquitto_publish
            mosquitto_subscribe
            mosquitto_unsubscribe
            mosquitto_loop_forever
            mosquitto_loop
            mosquitto_loop_start
            mosquitto_loop_stop
            mosquitto_loop_read
            mosquitto_loop_write
            mosquitto_loop_misc
            mosquitto_want_write
            mosquitto_socks5_set
            mosquitto_int_option
            mosquitto_string_option
            mosquitto_reconnect_delay_set
            mosquitto_tls_set
            mosquitto_tls_insecure_set
            mosquitto_tls_opts_set
            mosquitto_tls_psk_set
            mosquitto_connect_callback_set
            mosquitto_connect_callback_set
            mosquitto_disconnect_callback_set
            mosquitto_publish_callback_set
            mosquitto_message_callback_set
            mosquitto_subscribe_callback_set
            mosquitto_unsubscribe_callback_set
            mosquitto_log_callback_set
            mosquitto_strerror
            mosquitto_connack_string
            mosquitto_reason_string
            mosquitto_pub_topic_check
            mosquitto_sub_topic_check
            mosquitto_message_mid
            mosquitto_message_topic
            mosquitto_message_payloadlen
            mosquitto_message_qos
            mosquitto_message_retain
            on_connect)
  (c-declare "#include <mosquitto.h>")
  (c-declare "#include <mqtt_protocol.h>")
  (c-initialize "mosquitto_lib_init();")

  (c-define-type mosquitto* (pointer (struct "mosquitto")))
  (c-define-type mosquitto_message* (pointer (struct "mosquitto_message")))
  (c-define-type mosquitto_opt int)

  (define-const MOSQ_LOG_INFO)
  (define-const MOSQ_LOG_NOTICE)
  (define-const MOSQ_LOG_WARNING)
  (define-const MOSQ_LOG_ERR)
  (define-const MOSQ_LOG_DEBUG)

  (define-const MOSQ_ERR_SUCCESS)
  (define-const MOSQ_ERR_AUTH_CONTINUE)
  (define-const MOSQ_ERR_NO_SUBSCRIBERS)
  (define-const MOSQ_ERR_SUB_EXISTS)
  (define-const MOSQ_ERR_CONN_PENDING)
  (define-const MOSQ_ERR_NOMEM)
  (define-const MOSQ_ERR_PROTOCOL)
  (define-const MOSQ_ERR_INVAL)
  (define-const MOSQ_ERR_NO_CONN)
  (define-const MOSQ_ERR_CONN_REFUSED)
  (define-const MOSQ_ERR_NOT_FOUND)
  (define-const MOSQ_ERR_CONN_LOST)
  (define-const MOSQ_ERR_TLS)
  (define-const MOSQ_ERR_PAYLOAD_SIZE)
  (define-const MOSQ_ERR_NOT_SUPPORTED)
  (define-const MOSQ_ERR_AUTH)
  (define-const MOSQ_ERR_ACL_DENIED)
  (define-const MOSQ_ERR_UNKNOWN)
  (define-const MOSQ_ERR_ERRNO)
  (define-const MOSQ_ERR_EAI)
  (define-const MOSQ_ERR_PROXY)
  (define-const MOSQ_ERR_PLUGIN_DEFER)
  (define-const MOSQ_ERR_MALFORMED_UTF8)
  (define-const MOSQ_ERR_KEEPALIVE)
  (define-const MOSQ_ERR_LOOKUP)
  (define-const MOSQ_ERR_MALFORMED_PACKET)
  (define-const MOSQ_ERR_DUPLICATE_PROPERTY)
  (define-const MOSQ_ERR_TLS_HANDSHAKE)
  (define-const MOSQ_ERR_QOS_NOT_SUPPORTED)
  (define-const MOSQ_ERR_OVERSIZE_PACKET)
  (define-const MOSQ_ERR_OCSP)
  (define-const MOSQ_ERR_TIMEOUT)
  (define-const MOSQ_ERR_RETAIN_NOT_SUPPORTED)
  (define-const MOSQ_ERR_TOPIC_ALIAS_INVALID)
  (define-const MOSQ_ERR_ADMINISTRATIVE_ACTION)
  (define-const MOSQ_ERR_ALREADY_EXISTS)

  (define-const CONNACK_ACCEPTED)
  (define-const CONNACK_REFUSED_PROTOCOL_VERSION)
  (define-const CONNACK_REFUSED_IDENTIFIER_REJECTED)
  (define-const CONNACK_REFUSED_SERVER_UNAVAILABLE)
  (define-const CONNACK_REFUSED_BAD_USERNAME_PASSWORD)
  (define-const CONNACK_REFUSED_NOT_AUTHORIZED)

  (define MOSQ_OPT_PROTOCOL_VERSION ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_PROTOCOL_VERSION;")))
  (define MOSQ_OPT_SSL_CTX ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_SSL_CTX;")))
  (define MOSQ_OPT_SSL_CTX_WITH_DEFAULTS ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_SSL_CTX_WITH_DEFAULTS;")))
  (define MOSQ_OPT_RECEIVE_MAXIMUM ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_RECEIVE_MAXIMUM;")))
  (define MOSQ_OPT_SEND_MAXIMUM ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_SEND_MAXIMUM;")))
  (define MOSQ_OPT_TLS_KEYFORM ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TLS_KEYFORM;")))
  (define MOSQ_OPT_TLS_ENGINE ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TLS_ENGINE;")))
  (define MOSQ_OPT_TLS_ENGINE_KPASS_SHA1 ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TLS_ENGINE_KPASS_SHA1;")))
  (define MOSQ_OPT_TLS_OCSP_REQUIRED ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TLS_OCSP_REQUIRED;")))
  (define MOSQ_OPT_TLS_ALPN ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TLS_ALPN;")))
  (define MOSQ_OPT_TCP_NODELAY ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TCP_NODELAY;")))
  (define MOSQ_OPT_BIND_ADDRESS ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_BIND_ADDRESS;")))
  (define MOSQ_OPT_TLS_USE_OS_CERTS ((c-lambda () mosquitto_opt "___result = MOSQ_OPT_TLS_USE_OS_CERTS;")))

  (define-c-lambda mosquitto_new (char-string bool (pointer void)) mosquitto* "mosquitto_new")
  (define-c-lambda mosquitto_destroy (mosquitto*) void "mosquitto_destroy")
  (define-c-lambda mosquitto_lib_version ((pointer int) (pointer int) (pointer int)) int "mosquitto_lib_version")
  (define-c-lambda mosquitto_reinitialise (mosquitto* char-string bool (pointer void)) int "mosquitto_reinitialise")
  (define-c-lambda mosquitto_will_set (mosquitto* char-string int char-string int bool) int "mosquitto_will_set")
  (define-c-lambda mosquitto_will_clear (mosquitto*) int "mosquitto_will_clear")
  (define-c-lambda mosquitto_username_pw_set (mosquitto* char-string char-string) int "mosquitto_username_pw_set")
  (define-c-lambda mosquitto_connect (mosquitto* char-string int int) int "mosquitto_connect")
  (define-c-lambda mosquitto_connect_bind (mosquitto* char-string int int char-string) int "mosquitto_connect_bind")
  (define-c-lambda mosquitto_connect_async (mosquitto* char-string int int) int "mosquitto_connect_async")
  (define-c-lambda mosquitto_connect_bind_async (mosquitto* char-string int int char-string) int "mosquitto_connect_bind_async")
  (define-c-lambda mosquitto_disconnect (mosquitto*) int "mosquitto_disconnect")
  (define-c-lambda mosquitto_reconnect (mosquitto*) int "mosquitto_reconnect")
  (define-c-lambda mosquitto_reconnect_async (mosquitto*) int "mosquitto_reconnect_async")
  (define-c-lambda mosquitto_publish (mosquitto* (pointer int) char-string int (pointer void) int bool) int "mosquitto_publish")
  (define-c-lambda mosquitto_subscribe (mosquitto* (pointer int) char-string int) int "mosquitto_subscribe")
  (define-c-lambda mosquitto_unsubscribe (mosquitto* (pointer int) char-string) int "mosquitto_unsubscribe")
  (define-c-lambda mosquitto_loop_forever (mosquitto* int int) int "mosquitto_loop_forever")
  (define-c-lambda mosquitto_loop (mosquitto* int int) int "mosquitto_loop")
  (define-c-lambda mosquitto_loop_start (mosquitto*) int "mosquitto_loop_start")
  (define-c-lambda mosquitto_loop_stop (mosquitto* bool) int "mosquitto_loop_stop")
  (define-c-lambda mosquitto_loop_read (mosquitto* int) int "mosquitto_loop_read")
  (define-c-lambda mosquitto_loop_write (mosquitto* int) int "mosquitto_loop_write")
  (define-c-lambda mosquitto_loop_misc (mosquitto*) int "mosquitto_loop_misc")
  (define-c-lambda mosquitto_want_write (mosquitto*) bool "mosquitto_want_write")
  (define-c-lambda mosquitto_socks5_set (mosquitto* char-string int char-string char-string) int "mosquitto_socks5_set")
  (define-c-lambda mosquitto_int_option (mosquitto* mosquitto_opt int) int "mosquitto_int_option")
  (define-c-lambda mosquitto_string_option (mosquitto* mosquitto_opt char-string) int "mosquitto_string_option")
  (define-c-lambda mosquitto_reconnect_delay_set (mosquitto* int int bool) int "mosquitto_reconnect_delay_set")
  ;; todo: support password callback so it will not disturb stdin (as per docs it will if callback is not provided)
  (define-c-lambda mosquitto_tls_set (mosquitto* char-string char-string char-string char-string (function (char-string int int (pointer void)) int)) int "mosquitto_tls_set")
  (define-c-lambda mosquitto_tls_insecure_set (mosquitto* bool) int "mosquitto_tls_insecure_set")
  (define-c-lambda mosquitto_tls_opts_set (mosquitto* int char-string char-string) int "mosquitto_tls_opts_set")
  (define-c-lambda mosquitto_tls_psk_set (mosquitto* char-string char-string char-string) int "mosquitto_tls_psk_set")

  (c-declare "
    void mosquitto_message_callback_set_wrapper(struct mosquitto *mosq, void (*on_message)(struct mosquitto *, void *, struct mosquitto_message *))
    {
      mosquitto_message_callback_set(mosq, (void (*)(struct mosquitto *, void *, const struct mosquitto_message *))on_message);
    }
    void mosquitto_subscribe_callback_set_wrapper(struct mosquitto *mosq, void (*on_subscribe)(struct mosquitto *, void *, int, int, int *))
    {
      mosquitto_subscribe_callback_set(mosq, (void (*)(struct mosquitto *, void *, int, int, const int *))on_subscribe);
    }
    void mosquitto_log_callback_set_wrapper(struct mosquitto *mosq, void (*on_log)(struct mosquitto *, void *, int, char *))
    {
      mosquitto_log_callback_set(mosq, (void (*)(struct mosquitto *, void *, int, const char *))on_log);
    }
  ")
  (define-c-lambda mosquitto_connect_callback_set (mosquitto* (function (mosquitto* (pointer void) int) void)) void "mosquitto_connect_callback_set")
  (define-c-lambda mosquitto_connect_callback_set (mosquitto* (function (mosquitto* (pointer void) int) void)) void "mosquitto_connect_callback_set")
  (define-c-lambda mosquitto_disconnect_callback_set (mosquitto* (function (mosquitto* (pointer void) int) void)) void "mosquitto_disconnect_callback_set")
  (define-c-lambda mosquitto_publish_callback_set (mosquitto* (function (mosquitto* (pointer void) int) void)) void "mosquitto_publish_callback_set")
  (define-c-lambda mosquitto_message_callback_set (mosquitto* (function (mosquitto* (pointer void) mosquitto_message*) void)) void "mosquitto_message_callback_set_wrapper")
  (define-c-lambda mosquitto_subscribe_callback_set (mosquitto* (function (mosquitto* (pointer void) int int (pointer int)) void)) void "mosquitto_subscribe_callback_set_wrapper")
  (define-c-lambda mosquitto_unsubscribe_callback_set (mosquitto* (function (mosquitto* (pointer void) int) void)) void "mosquitto_unsubscribe_callback_set")
  (define-c-lambda mosquitto_log_callback_set (mosquitto* (function (mosquitto* (pointer void) int char-string) void)) void "mosquitto_log_callback_set_wrapper")

  (define-c-lambda mosquitto_strerror (int) char-string "___return((char*)mosquitto_strerror(___arg1));")
  (define-c-lambda mosquitto_connack_string (int) char-string "___return((char*)mosquitto_connack_string(___arg1));")
  (define-c-lambda mosquitto_reason_string (int) char-string "___return((char*)mosquitto_reason_string(___arg1));")
  (define-c-lambda mosquitto_pub_topic_check (char-string) int "mosquitto_pub_topic_check")
  (define-c-lambda mosquitto_sub_topic_check (char-string) int "mosquitto_sub_topic_check")
  (define-c-lambda mosquitto_message_mid (mosquitto_message*) int "___return(___arg1->mid);")
  (define-c-lambda mosquitto_message_topic (mosquitto_message*) char-string "___return(___arg1->topic);")
  (define-c-lambda mosquitto_message_payloadlen (mosquitto_message*) int "___return(___arg1->payloadlen);")
  (define-c-lambda mosquitto_message_qos (mosquitto_message*) int "___return(___arg1->qos);")
  (define-c-lambda mosquitto_message_retain (mosquitto_message*) bool "___return(___arg1->retain);")

  (c-define (on_connect ptr user-data rc) (mosquitto* (pointer void) int)
            void "mosquitto_on_connect" ""
            (unless (eq? rc CONNACK_ACCEPTED)
              (error (mosquitto_connack_string rc)
                (cond
                 ((= rc CONNACK_REFUSED_NOT_AUTHORIZED) 'not-authorized)
                 ((= rc CONNACK_REFUSED_BAD_USERNAME_PASSWORD) 'bad-username-password)
                 ((= rc CONNACK_REFUSED_SERVER_UNAVAILABLE) 'server-unavailable)
                 ((= rc CONNACK_REFUSED_IDENTIFIER_REJECTED) 'identifier-rejected)
                 ((= rc CONNACK_REFUSED_PROTOCOL_VERSION) 'protocol-version)
                 (else 'unknown))))
            (let* ((client (table-ref mosquitto-clients (foreign-address ptr)))
                   (callback (mosquitto-client-on-connect client)))
              (when (procedure? callback)
                (callback client)))))

;;

(def (assert-errno result)
  (if (null? result)
    (error (mosquitto_strerror MOSQ_ERR_ERRNO))
    result))

(def (assert-ret-code rc (context #f))
  (if (eq? rc MOSQ_ERR_SUCCESS)
    rc
    (error (mosquitto_strerror rc) context)))

;;

(def mosquitto-log-levels
    (list [MOSQ_LOG_INFO . 'log-info]
          [MOSQ_LOG_NOTICE . 'log-notice]
          [MOSQ_LOG_WARNING . 'log-warning]
          [MOSQ_LOG_ERR . 'log-err]
          [MOSQ_LOG_DEBUG . 'log-debug]))

;;

(def mosquitto-clients
  (make-table weak-keys: #t weak-values: #t))

(def (mosquitto-client-register! mosquitto)
  (table-set! mosquitto-clients
              (foreign-address (mosquitto-client-ptr mosquitto))
              mosquitto))

;;

(defstruct mosquitto-client
  (ptr
   user-data
   on-connect
   on-disconnect
   on-publish
   on-message
   on-subscribe
   on-unsubscribe
   on-log)
  constructor: :init!)

(defmethod {:init! mosquitto-client}
  (lambda (self id: (id #f)
                clean-session: (clean-session #t)
                user-data: (user-data #f)
                on-connect: (on-connect #f)
                on-disconnect: (on-disconnect #f)
                on-publish: (on-publish #f)
                on-message: (on-message #f)
                on-subscribe: (on-subscribe #f)
                on-unsubscribe: (on-unsubscribe #f)
                on-log: (on-log #f))
    (let ((ptr (assert-errno (mosquitto_new id clean-session #f))))
      (set! (@ self ptr) ptr)
      (set! (@ self user-data) user-data)
      (mosquitto-client-register! self)
      (make-will ptr
                 (lambda (ptr) ;; todo: unregister here?
                   (mosquitto_destroy ptr)))
      (mosquitto_connect_callback_set ptr on_connect)
      ;; (mosquitto_disconnect_callback_set mosquitto (location disconnect_cb))
      ;; (mosquitto_publish_callback_set mosquitto (location publish_cb))
      ;; (mosquitto_message_callback_set mosquitto (location message_cb))
      ;; (mosquitto_subscribe_callback_set mosquitto (location subscribe_cb))
      ;; (mosquitto_unsubscribe_callback_set mosquitto (location unsubscribe_cb))
      ;; (mosquitto_log_callback_set mosquitto (location log_cb))
      ;; ;; attach user callbacks
      (set! (@ self on-connect) on-connect)
      ;; (set-mosquitto-client-connect-callback! client on-connect)
      ;; (set-mosquitto-client-disconnect-callback! client on-disconnect)
      ;; (set-mosquitto-client-publish-callback! client on-publish)
      ;; (set-mosquitto-client-message-callback! client on-message)
      ;; (set-mosquitto-client-subscribe-callback! client on-subscribe)
      ;; (set-mosquitto-client-unsubscribe-callback! client on-unsubscribe)
      ;; (set-mosquitto-client-log-callback! client on-log)
      self)))

(defmethod {connect! mosquitto-client}
  (lambda (self host: (host "127.0.0.1")
                port: (port 1883)
                username: (username #f)
                password: (password #f)
                keepalive: (keepalive 5)
                bind-address: (bind-address #f)
                tls-cafile: (tls-cafile #f)
                tls-capath: (tls-capath #f)
                tls-certfile: (tls-certfile #f)
                tls-keyfile: (tls-keyfile #f)
                tls-insecure: (tls-insecure #f)
                tls-ocsp-required: (tls-ocsp-required #f)
                tls-use-os-certs: (tls-use-os-certs #f)
                tls-alpn: (tls-alpn #f)
                socks5-host: (socks5-host #f)
                socks5-port: (socks5-port 1080)
                socks5-username: (socks5-username #f)
                socks5-password: (socks5-password #f)
                reconnect-delay: (reconnect-delay 1)
                reconnect-delay-max: (reconnect-delay-max 10)
                reconnect-exp-backoff: (reconnect-exp-backoff #f)
                tcp-nodelay: (tcp-nodelay #t))
    (begin0 self
      (let ((ptr (mosquitto-client-ptr self)))
        (when (and username password)
          (assert-ret-code (mosquitto_username_pw_set ptr username password) 'username/password))
        (when (or tls-cafile tls-capath tls-certfile tls-keyfile)
          (assert-ret-code (mosquitto_tls_set ptr tls-cafile tls-capath tls-certfile tls-keyfile #f) 'tls))
        (unless tls-insecure
          (assert-ret-code (mosquitto_tls_insecure_set ptr #f) 'tls-insecure))
        (when tls-ocsp-required
          (assert-ret-code (mosquitto_int_option ptr MOSQ_OPT_TLS_OCSP_REQUIRED 1) 'tls-ocsp-required))
        (when tls-use-os-certs
          (assert-ret-code (mosquitto_int_option ptr MOSQ_OPT_TLS_USE_OS_CERTS 1) 'tls-use-os-certs))
        (when tls-alpn
          (assert-ret-code (mosquitto_string_option ptr MOSQ_OPT_TLS_ALPN tls-alpn) 'tls-alpn))
        (when bind-address
          (assert-ret-code (mosquitto_string_option ptr MOSQ_OPT_BIND_ADDRESS bind-address) 'bind-address))
        (when socks5-host
          (assert-ret-code (mosquitto_socks5_set ptr socks5-host socks5-port socks5-username socks5-password) 'socks5))
        (when tcp-nodelay
          (assert-ret-code (mosquitto_int_option ptr MOSQ_OPT_TCP_NODELAY 1) 'tcp-nodelay))
        (assert-ret-code (mosquitto_reconnect_delay_set ptr reconnect-delay reconnect-delay-max reconnect-exp-backoff) 'reconnect-delay)
        (assert-ret-code (mosquitto_connect ptr host port keepalive) 'connect)))))

(defmethod {loop mosquitto-client}
  (lambda (self (timeout 1000))
    (assert-ret-code (mosquitto_loop self.ptr timeout 1) 'loop)))

(defmethod {loop-forever mosquitto-client}
  (lambda (self (timeout 1000))
    (assert-ret-code (mosquitto_loop_forever self.ptr timeout 1) 'loop-forever)))

;;

(defstruct mosquitto-message
  (id topic payload qos retain)
  transparent: #t)
