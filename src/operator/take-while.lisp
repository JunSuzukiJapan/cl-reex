(in-package :cl-user)
(defpackage cl-reex.operator.take-while
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
  (:export :operator-take-while
	   :take-while
	   :make-operator-take-while))

(in-package :cl-reex.operator.take-while)


(defclass operator-take-while (operator)
  ((predicate :initarg :predicate
	      :accessor predicate )
   (completed :initarg :completed
	      :initform nil
	      :accessor completed ))
  (:documentation "Take-While operator"))

(defun make-operator-take-while (observable predicate)
  (let ((op (make-instance 'operator-take-while
		 :observable observable
		 :predicate predicate )))
    (set-on-next
          #'(lambda (x)
	      (if (funcall (predicate op) x)
  		  (funcall (get-on-next (observer op)) x)
		  (when (not (completed op))
		    (setf (completed op) t)
		    (funcall (get-on-completed (observer op))) )))
	  op )
    (set-on-error
	  #'(lambda (x)
	      (funcall (on-error (observer op)) x) )
	  op )
    (set-on-completed
          #'(lambda () ) ;; do nothing
	  op )
    op ))


(defmethod subscribe ((op operator-take-while) observer)
  (setf (completed op) nil)
  (call-next-method) )

;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-take-while
;;                       temp-observable
;;                       #'(lambda (x) (evenp x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;

(set-operator-expander 'take-while
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-take-while
	   ,temp-observable
	   #'(lambda ,(cadr x) ,(caddr x) )))))

