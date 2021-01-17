(defpackage amb-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :amb-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~A" x)))
    #'(lambda () (add logger "completed")) ))

;; plan 1

(defvar observable1 (with-observable (observable-timer 0.1)
  (concat (observable-of 0.1 0.1)) ))

(defvar observable2 (with-observable (observable-timer 0.05)
  (concat (observable-of 0.05 0.05)) ))

(defvar subscription (with-observable observable1
  (amb observable2)
  (subscribe observer) ))

(sleep 0.35)

(dispose subscription)
 
(is (result logger)
    '(55 "completed") )

(finalize)
