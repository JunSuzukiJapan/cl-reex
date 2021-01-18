(defpackage observable-amb-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-amb-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 1)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(defvar observable1 (with-observable (observable-timer 0.1)
  (do :on-next #'(lambda (x)
                   (declare (ignore x))
                   (add logger (format nil "call 0.1"))))
  (concat (observable-of "observable-of: 0.1")) ))

(defvar observable2 (with-observable (observable-timer 0.05)
  (do :on-next #'(lambda (x)
                   (declare (ignore x))
                   (add logger (format nil "call 0.05"))))
  (concat (observable-of "observable-of: 0.05")) ))

(defvar subscription (with-observable (observable-amb
                                       observable1
                                       observable2 )
  (subscribe observer) ))

(sleep 0.12)

(dispose subscription)
 
(is (result logger)
    '("call 0.05" 0 "observable-of: 0.05" "completed") )

(finalize)
