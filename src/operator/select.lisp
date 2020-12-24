(in-package :cl-user)
(defpackage cl-reex.operator.select
  (:use :cl)
  (:import-from :cl-reex.observer
 		:observer
		:on-next
		:on-error
		:on-completed)
  (:import-from :cl-reex.observable
		:subscribe)
  (:import-from :cl-reex.macro.operator-table
		:get-operator-expander
		:set-operator-expander)
  (:import-from :cl-reex.macro.symbols
		:select )
  (:import-from :cl-reex.operator
		:operator
		:observable
		:predicate
		:func)
  (:export :operator-select
	   :make-operator-select))

(in-package :cl-reex.operator.select)


(defclass operator-select (operator)
  ((observable :initarg :observable
	       :accessor observable)
   (func :initarg :func
	 :accessor func)
   (observer :initarg :observer
	     :accessor observer) )
  (:documentation "Select operator"))

(defun make-operator-select (observable func)
  (let ((op (make-instance 'operator-select
		 :observable observable
		 :func func )))
    (setf (on-next op)
	  #'(lambda (x)
	      (let((temp (funcall (func op) x)))
	  	(funcall (on-next (observer op)) temp) )))
    (setf (on-error op)
	  #'(lambda (x)
	      (funcall (on-error (observer op))) ))
    (setf (on-completed op)
	  #'(lambda ()
	      (funcall (on-completed (observer op))) ))
    op ))


(defmethod subscribe ((op operator-select) observer)
  (setf (observer op) observer)
  (subscribe (observable op) op) )

;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-select
;;                       temp-observable
;;                       #'(lambda (x) (* x x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;
(set-operator-expander 'select
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-select
	   ,temp-observable
	   #'(lambda ,(cadr x) ,(caddr x) )))))
