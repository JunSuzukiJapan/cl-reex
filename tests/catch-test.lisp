(defpackage catch-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :catch-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1
(with-observable (handmade-observable
                  (on-next 1)
                  (on-next 2)
                  (on-error "some error")
                  (on-next 3)
                  (on-completed) )
  (catch* (observable-of 20))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 20 "completed"))

;; plan 2
(reset logger)

(with-observable (handmade-observable
                  (on-next 3)
                  (on-next 2)
                  (on-next 1)
                  (on-next 0)
                  (on-completed) )
  (select (x) (/ 6 x))
  (catch* (condition division-by-zero)
          (declare (ignore condition))
          (observable-of 20 21 22) )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(2 3 6 20 21 22 "completed"))

;; plan 3
(reset logger)

(handler-case
    (with-observable (handmade-observable
                      (on-next 3)
                      (on-next 2)
                      (on-next 1)
                      (on-next 0)
                      (on-completed) )
      (select (x) (/ 6 x))
      (catch* (condition not-existing-error)
              (declare (ignore condition))
              (observable-of 20 21 22) )
      (subscribe observer)
      (dispose) )
  (condition (c)
    (declare (ignore c))
    (add logger "error handled") ))

(is (result logger)
    '(2 3 6 "error handled"))

;; finalize
(finalize)
