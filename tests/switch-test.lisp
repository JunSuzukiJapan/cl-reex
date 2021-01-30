(defpackage switch-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :switch-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
  (on-next (x) (add logger x))
  (on-error (x) (add logger (format nil "error: ~A" x)))
  (on-completed () (add logger "completed")) ))

;; plan 1

(defvar observable1 (with-observable (observable-interval 0.1)
  (do (on-next (x)
               (declare (ignore x))
               (add logger (format nil "call 0.1" ))))))

(defparameter observable2 (with-observable (observable-interval 0.07)
  (do (on-next (x)
               (declare (ignore x))
               (add logger (format nil "call 0.07" ))))))

(defparameter subscription (with-observable (observable-of observable1 observable2)
  (switch)
  (subscribe observer) ))

(sleep 0.23)

(dispose subscription)
 
(is (result logger)
    '("call 0.07"
      0
      "call 0.1"
      0
      "call 0.1"
      1 ))


;; finalize
(finalize)
