(in-package :cl-user)
(defpackage cl-reex.macro.operator-table
  (:use :cl)
  (:export :set-operator
	   :get-operator ))

(in-package :cl-reex.macro.operator-table)

(defvar *op-table* (make-hash-table))

(defun get-operator (name)
  (gethash name *op-table*))

(defun set-operator (name op)
  (setf (gethash name *op-table*) op) )
