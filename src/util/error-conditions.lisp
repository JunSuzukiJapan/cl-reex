(in-package :cl-user)
(defpackage cl-reex.error-conditions
  (:use :cl)
  (:export :sequence-contaions-no-elements-error) )


(in-package :cl-reex.error-conditions)

(define-condition sequence-contaions-no-elements-error (simple-error)
  () )
