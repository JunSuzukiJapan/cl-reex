(defpackage count-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :count-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~A" x)))
    #'(lambda () (add logger "completed")) ))

;; plan 1

(with-observable (observable-range 1 10)
  (count)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(10 "completed") )

;; plan 2
(reset logger)

(with-observable (observable-of 30 15 8 77 2 60 22)
  (count (x) (> x 15))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(4 "completed") )

(finalize)
