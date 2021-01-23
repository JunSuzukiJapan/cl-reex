(defpackage synchronize-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :synchronize-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~S" x)))
    (on-completed () (add logger "completed")) ))

;;
;; plane 1
;;  unneed synchronize test
;;
(with-observable (observable-range 1 3)
  (synchronize)
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 "completed") )

;; finalize
(finalize)
