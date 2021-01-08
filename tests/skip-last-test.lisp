(defpackage take-last-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :take-last-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~S" x)))
    #'(lambda () (add logger "completed")) ))

;; plan 1
(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (skip-last 3)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 4 5 6 7 "completed"))

;; plan 2
(reset logger)

(with-observable (observable-empty)
  (skip-last 3)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("completed"))

(finalize)
