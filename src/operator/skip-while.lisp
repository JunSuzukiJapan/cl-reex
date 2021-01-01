(in-package :cl-user)
(defpackage cl-reex.operator.skip-while
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
		:predicate)
  (:export :operator-skip-while
	   :skip-while
	   :make-operator-skip-while))

(in-package :cl-reex.operator.skip-while)


(defclass operator-skip-while (operator)
  ((predicate :initarg :predicate
	      :accessor predicate )
   (completed :initarg :completed
	      :initform nil
	      :accessor completed ))
  (:documentation "Skip-While operator"))

(defun make-operator-skip-while (observable predicate)
  (let ((op (make-instance 'operator-skip-while
		 :observable observable
		 :predicate predicate )))
    (set-on-next
          #'(lambda (x)
	      (if (completed op)
  		  (funcall (get-on-next (observer op)) x)
		(when (not (funcall (predicate op) x))
		    (setf (completed op) t)
  		    (funcall (get-on-next (observer op)) x) )))
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


(defmethod subscribe ((op operator-skip-while) observer)
  (setf (completed op) nil)
  (call-next-method) )

;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-skip-while
;;                       temp-observable
;;                       #'(lambda (x) (evenp x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;

(set-operator-expander 'skip-while
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-skip-while
	   ,temp-observable
	   #'(lambda ,(cadr x) ,(caddr x) )))))

