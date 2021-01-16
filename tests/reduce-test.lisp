(defpackage reduce-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :reduce-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~A" x)))
    #'(lambda () (add logger "completed")) ))

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (reduce (x y) (+ x y))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(55 "completed") )

(finalize)
