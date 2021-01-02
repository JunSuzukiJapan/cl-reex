(in-package :cl-user)
(defpackage cl-reex.macro.operator-table
  (:use :cl)
  (:export :set-one-arg-operator
	   :set-function-operator
	   :set-operator-expander
	   :get-operator-expander ))

(in-package :cl-reex.macro.operator-table)

(defparameter *op-table* (make-hash-table))

(defun get-operator-expander (name)
  (gethash name *op-table*))

(defun set-operator-expander (name op)
  (setf (gethash name *op-table*) op) )


;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-where
;;                       temp-observable
;;                       #'(lambda (x) (evenp x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;
(defun set-function-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (,function-name
	   ,temp-observable
	   #'(lambda ,(cadr x) ,(caddr x) ))))))

(defun set-one-arg-operator (name function-name)
  (set-operator-expander name
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (,function-name
	   ,temp-observable
	   ,(cadr x) )))))

