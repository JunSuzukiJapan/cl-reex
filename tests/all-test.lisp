(defpackage all-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :all-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-from '(1 2 3 4 5 6 7 8 9 10))
  (all (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(nil "completed") )

;; plan 2
(reset logger)

(with-observable (observable-from '(2 4 6 8 10))
  (all (x) (evenp x))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(t "completed") )

;; finalize
(finalize)
