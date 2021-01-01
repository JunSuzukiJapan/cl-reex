(in-package :cl-user)
(defpackage cl-reex.operator.select
  (:use :cl)
  (:import-from :cl-reex.observer
 		:observer
		:on-next
		:on-error
		:on-completed)
  (:import-from :cl-reex.observable
		:observable
		:dispose
		:get-on-next
		:set-on-next
		:get-on-error
		:set-on-error
		:get-on-completed
		:set-on-completed
		:subscribe)
  (:import-from :cl-reex.macro.operator-table
		:get-operator-expander
		:set-operator-expander)
  (:import-from :cl-reex.operator
		:operator
		:predicate
		:func)
  (:export :operator-select
	   :select
	   :make-operator-select))

(in-package :cl-reex.operator.select)


(defclass operator-select (operator)
  ((func :initarg :func
	 :accessor func) )
  (:documentation "Select operator"))

(defun make-operator-select (observable func)
  (let ((op (make-instance 'operator-select
		 :observable observable
		 :func func )))
    (set-on-next
	  #'(lambda (x)
	      (let((temp (funcall (func op) x)))
	  	(funcall (get-on-next (observer op)) temp) ))
	  op )
    (set-on-error
	  #'(lambda (x)
	      (funcall (get-on-error (observer op)) x) )
	  op )
    (set-on-completed
	  #'(lambda ()
	      (funcall (get-on-completed (observer op))) )
	  op )
    op ))

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
