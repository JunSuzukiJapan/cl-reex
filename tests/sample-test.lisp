(defpackage sample-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip) )
(in-package :sample-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1
(defparameter subscription (with-observable (observable-interval 0.1)
  (sample 0.21)
  (subscribe observer) ))

(sleep 0.68)

(dispose subscription)

(is (result logger)
    '(1 3 5) )

;; plan 2
(defparameter subscription (with-observable (observable-interval 0.1)
  (sample (observable-interval 0.21))
  (subscribe observer) ))

(sleep 0.68)

(dispose subscription)

(is (result logger)
    '(1 3 5) )

;; finalize
(finalize)
