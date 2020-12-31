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
		:get-operator-expander
		:set-operator-expander)
  (:import-from :cl-reex.macro.symbols
		:skip )
  (:import-from :cl-reex.operator
		:operator
		:predicate)
  (:export :operator-skip
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

;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-skip
;;                       temp-observable
;;                       #'(lambda (x) (evenp x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;

(set-operator-expander 'skip
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-skip
	   ,temp-observable
	   ,(cadr x) ))))
