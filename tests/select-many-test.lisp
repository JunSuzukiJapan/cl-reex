(defpackage select-many-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :select-many-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
  (on-next (x) (add logger x))
  (on-error (x) (add logger (format nil "error: ~A" x)))
  (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-of 1 10 20)
  (select-many (x) (observable-range x 3))
  (subscribe observer) )
 
(is (result logger)
    '(1 2 3 10 11 12 20 21 22 "completed") )

;; plan 2
(reset logger)

(defparameter subscription (with-observable (observable-of '("No.1" 0.1) '("No.2" 0.05))
  (select-many (lst)
               (with-observable (observable-timer (cadr lst))
                 (do (on-next (x)
                              (declare (ignore x))
                              (add logger (format nil "call do ~A" (car lst))) ))
                 (concat (observable-of (format  nil "concat ~A" (car lst)))) ))
  (subscribe observer) ))

(sleep 0.2)

(dispose subscription)
 
(is (result logger)
    '("call do No.1"
      0
      "concat No.1"
      "call do No.2"
      0
      "concat No.2"
      "completed" ))

;; finalize
(finalize)
