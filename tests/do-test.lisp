(defpackage do-test
  (:use :cl
    :cl-reex
    :cl-reex-test.logger
    :prove)
  (:shadowing-import-from :cl-reex :skip))
(in-package :do-test)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-reex)' in your Lisp.

(plan 3)

;; blah blah blah.

(defparameter logger (make-instance 'logger))

(defparameter observer (make-observer
    (on-next (x) (add logger x))
    (on-error (x) (add logger (format nil "error: ~A" x)))
    (on-completed () (add logger "completed")) ))

;; plan 1

(with-observable (observable-of 1 2 3)
  (do :on-next #'(lambda (x) (add logger (format nil "do: ~A" x))))
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("do: 1" 1 "do: 2" 2 "do: 3" 3 "completed"))

;; plan 2
(reset logger)

(with-observable (handmade-observable
                  (on-next 1)
                  (on-next 2)
                  (on-error "some error")
                  (on-next 3)
                  (on-completed) )
  (do
   :on-next #'(lambda (x) (add logger (format nil "do: ~A" x)))
   :on-error #'(lambda (x) (add logger (format nil "do error: ~A" x)))
   :on-completed #'(lambda () (add logger (format nil "do completed"))) )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("do: 1" 1 "do: 2" 2 "do error: some error" "error: some error") )

;; plan 3
(reset logger)

(with-observable (handmade-observable
                  (on-next 1)
                  (on-next 2)
                  (on-next 3)
                  (on-completed) )
  (do
   :on-next #'(lambda (x) (add logger (format nil "do: ~A" x)))
   :on-error #'(lambda (x) (add logger (format nil "do error: ~A" x)))
   :on-completed #'(lambda () (add logger (format nil "do completed"))) )
  (subscribe observer)
  (dispose) )

(is (result logger)
    '("do: 1" 1 "do: 2" 2 "do: 3" 3 "do completed" "completed") )


;; finalize
(finalize)
