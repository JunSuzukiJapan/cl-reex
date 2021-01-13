(in-package :cl-user)
(defpackage cl-reex.error-conditions
  (:use :cl)
  (:export :sequence-contains-no-elements-error
           :argument-out-of-range-exception ))


(in-package :cl-reex.error-conditions)

(define-condition sequence-contains-no-elements-error (simple-error)
  () )

(define-condition argument-out-of-range-exception (simple-error)
  () )
