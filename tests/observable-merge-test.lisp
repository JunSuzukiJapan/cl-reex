(defpackage observable-merge-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :observable-merge-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 2)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-merge (observable-of
                                    (observable-range 1 3)
                                    (observable-range 10 3)
                                    (observable-range 20 3) ))
  (subscribe observer) )

(is (result logger)
    '(1 2 3 10 11 12 20 21 22 "completed") )

;; plan 2
(reset logger)

(defvar observable1 (with-observable (observable-timer 0.1)
  (do (on-next (x)
               (declare (ignore x))
               (add logger (format nil "call 0.1"))))
  (concat (observable-of "observable-of: 0.1")) ))

(defvar observable2 (with-observable (observable-timer 0.05)
  (do (on-next (x)
               (declare (ignore x))
               (add logger (format nil "call 0.05"))))
  (concat (observable-of "observable-of: 0.05")) ))

(defvar subscription (with-observable (observable-merge
                                       (observable-of
                                        observable1
                                        observable2 ))
  (subscribe observer) ))

(sleep 0.2)

(dispose subscription)
 
(is (result logger)
    '("call 0.1"
      0
      "observable-of: 0.1"
      "call 0.05"
      0
      "observable-of: 0.05"
      "completed" ))

(finalize)
