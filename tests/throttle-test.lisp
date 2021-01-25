(defpackage throttle-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip) )
(in-package :throttle-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

(defparameter subject (make-subject))

;; plan 1
(defparameter subscription (with-observable subject
  (throttle 0.1)
  (subscribe observer) ))

(on-next subject 0)
(sleep 0.05)
(on-next subject 1)
(sleep 0.05)
(on-next subject 2)
(sleep 0.12)
(on-next subject 3)
(on-next subject 4)
(on-next subject 5)
(sleep 0.12)
(on-next subject 6)
(on-completed subject)

(dispose subscription)

(is (result logger)
    '(2 5 "completed") )


;; finalize
(finalize)
