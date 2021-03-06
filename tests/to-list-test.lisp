(defpackage to-list-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip) )
(in-package :to-list-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (to-list)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '((1 2 3 4 5 6 7 8 9 10) "completed") )

(finalize)
