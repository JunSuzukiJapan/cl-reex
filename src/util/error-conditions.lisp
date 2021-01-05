(in-package :cl-user)
(defpackage cl-reex.error-conditions
  (:use :cl)
  (:export :sequence-contains-no-elements-error) )


(in-package :cl-reex.error-conditions)

(define-condition sequence-contains-no-elements-error (simple-error)
  () )
