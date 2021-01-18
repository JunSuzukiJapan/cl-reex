(defpackage finally-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :finally-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 4)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1
(with-observable (observable-range 1 5)
  (finally #'(lambda () (add logger "finally")))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 3 4 5 "completed" "finally") )

;; plan 2
(reset logger)

(with-observable (handmade-observable
                  (on-next 1)
                  (on-next 2)
                  (on-error "Some error")
                  (on-next 3)
                  (on-completed) )
  (finally #'(lambda () (add logger "finally")))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '(1 2 "error: Some error" "finally") )

;; plan 3
(reset logger)

(with-observable (observable-of 1 2 3)
  (where (x)
         (declare (ignore x))
         (error "some error") )
  (finally #'(lambda () (add logger "finally")))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("error: some error" "finally") )

;; plan 4
(reset logger)

(with-observable (observable-of 1 2 3)
  (finally #'(lambda () (add logger "finally")))
  (where (x)
         (declare (ignore x))
         (error "some error") )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("error: some error" "finally") )


(finalize)
