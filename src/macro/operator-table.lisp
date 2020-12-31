(in-package :cl-user)
(defpackage cl-reex.macro.operator-table
  (:use :cl)
  (:export :set-operator-expander
	   :get-operator-expander ))

(in-package :cl-reex.macro.operator-table)

(defparameter *op-table* (make-hash-table))

(defun get-operator-expander (name)
  (gethash name *op-table*))

(defun set-operator-expander (name op)
  (setf (gethash name *op-table*) op) )
