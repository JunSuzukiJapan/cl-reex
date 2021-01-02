(in-package :cl-user)
(defpackage cl-reex.operator.skip
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
		:set-one-arg-operator)
  (:import-from :cl-reex.operator
		:operator
		:predicate)
  (:export :operator-skip
	   :skip
	   :make-operator-skip))

(in-package :cl-reex.operator.skip)


(defclass operator-skip (operator)
  ((count :initarg :count
	  :accessor count-num)
   (current-count :initarg :current-count
		  :initform 0
		  :accessor current-count) )
  (:documentation "Skip operator"))

(defun make-operator-skip (observable count)
  (let ((op (make-instance 'operator-skip
		 :observable observable
		 :count count )))
    (set-on-next
	  #'(lambda (x)
	      (if (< (current-count op) (count-num op))
		(incf (current-count op))
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


(defmethod subscribe ((op operator-skip) observer)
  (setf (current-count op) 0)
  (call-next-method) )

(set-one-arg-operator 'skip 'make-operator-skip)

