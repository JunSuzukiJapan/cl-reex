(defpackage observable-timer-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-timer-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1
(defparameter timer (observable-timer 0.1))
(defparameter subscription (subscribe timer observer))

(sleep 0.15)

(dispose subscription)

(is (result logger)
    '(0 "completed") )

;; plan 2
(reset logger)
(setq timer (observable-timer 0.1 0.1))
(setq subscription (subscribe timer observer))

(sleep 0.38)

(dispose subscription)

(is (result logger)
    '(0 1 2) )

;; plan 3
(reset logger)
(setq timer (observable-interval 0.1))
(setq subscription (subscribe timer observer))

(sleep 0.38)

(dispose subscription)

(is (result logger)
    '(0 1 2) )

(finalize)
