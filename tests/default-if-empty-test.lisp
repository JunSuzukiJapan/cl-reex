(defpackage default-if-empty-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :default-if-empty-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-of 1 2 3)
  (default-if-empty 7)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 "completed") )

;; plan 2
(reset logger)

(with-observable (observable-empty)
  (default-if-empty 7)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(7 "completed") )

;; finalize
(finalize)
