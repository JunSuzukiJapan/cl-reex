(defpackage foreach-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :foreach-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; plan 1

(defparameter logger (make-instance 'logger))

(defparameter source (observable-range 1 10))

(foreach source
         #'(lambda (x) (add logger x)))

(is (result logger)
    '(1 2 3 4 5 6 7 8 9 10))

;; plan 2

(reset logger)

(defparameter observer (make-observer
    #'(lambda (x) (add logger x))
    #'(lambda (x) (add logger (format nil "error: ~S" x)))
    #'(lambda () (add logger "completed")) ))

(defparameter sub (make-subject))

(defparameter observable
  (with-observable sub
    (skip 3)
    (take 3)
    (repeat 3) ))

(defparameter subscription (subscribe observable observer))

(foreach (observable-range 1 20)
    #'(lambda (x) (on-next sub x)) )

(is (result logger)
    '(4 5 6 10 11 12 16 17 18 "completed") )


(finalize)
