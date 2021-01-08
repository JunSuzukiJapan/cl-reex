(defpackage distinct-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :distinct-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~S" x)))
    #'(lambda () (add logger "completed")) ))

(with-observable (observable-of 1 2 2 1 3)
  (distinct)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 "completed"))

(finalize)
