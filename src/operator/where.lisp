(in-package :cl-user)
(defpackage cl-reex.operator.where
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
  (:import-from :cl-reex.macro.symbols
		:where )
  (:import-from :cl-reex.operator
		:operator
		:predicate)
  (:export :operator-where
	   :make-operator-where))

(in-package :cl-reex.operator.where)


(defclass operator-where (operator)
  ((observable :initarg :observable
	       :accessor observable)
   (predicate :initarg :predicate
	      :accessor predicate)
   (observer :initarg :observer
	     :accessor observer)
   (subscription :initarg :subscription
		 :accessor subscription) )
  (:documentation "Where operator"))

(defun make-operator-where (observable predicate)
  (let ((op (make-instance 'operator-where
		 :observable observable
		 :predicate predicate )))
    (set-on-next
	  #'(lambda (x)
	      (when (funcall (predicate op) x)
	  	(funcall (get-on-next (observer op)) x) ))
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

(defmethod subscribe ((op operator-where) observer)
  (setf (observer op) observer)
  (when (slot-boundp op 'subscription)
    (dispose (subscription op)) )
  (setf (subscription op) (subscribe (observable op) op)) )


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
(set-operator-expander 'where
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-where
	   ,temp-observable
	   #'(lambda ,(cadr x) ,(caddr x) )))))
