(in-package :cl-user)
(defpackage cl-reex.operator.repeat
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
		:repeat )
  (:import-from :cl-reex.operator
		:operator
		:observable
		:predicate)
  (:export :operator-repeat
	   :make-operator-repeat))

(in-package :cl-reex.operator.repeat)


(defclass operator-repeat (operator)
  ((observable :initarg :observable
	       :accessor observable)
   (count :initarg :count
	  :accessor count-num)
   (current-count :initarg :current-count
		  :initform 0
		  :accessor current-count)
   (observer :initarg :observer
	     :accessor observer) )
  (:documentation "Repeat operator"))

(defun make-operator-repeat (observable count)
  (let ((op (make-instance 'operator-repeat
		 :observable observable
		 :count count )))
    (setf (on-next op)
	  #'(lambda (x)
	      (funcall (on-next (observer op)) x) ))
    (setf (on-error op)
	  #'(lambda (x)
	      (funcall (on-error (observer op))) ))
    (setf (on-completed op)
	  #'(lambda ()
	      (incf (current-count op))
	      (if (>= (current-count op) (count-num op))
		  (funcall (on-completed (observer op)))
		  (subscribe (observable op) op) )))
    op ))

(defmethod subscribe ((op operator-repeat) observer)
  (if (> (count-num op) 0)
      (progn
	(setf (observer op) observer)
	(setf (current-count op) 0)
	(subscribe (observable op) op) )
      (funcall (on-completed observer)) ))

(set-operator-expander 'repeat
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-repeat
	   ,temp-observable
	   ,(cadr x) ))))
