(in-package :cl-user)
(defpackage cl-reex.operator.skip
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
		:skip )
  (:import-from :cl-reex.operator
		:operator
		:observable
		:predicate)
  (:export :operator-skip
	   :make-operator-skip))

(in-package :cl-reex.operator.skip)


(defclass operator-skip (operator)
  ((observable :initarg :observable
	       :accessor observable)
   (count :initarg :count
	  :accessor count-num)
   (current-count :initarg :current-count
		  :initform 0
		  :accessor current-count)
   (observer :initarg :observer
	     :accessor observer) )
  (:documentation "Skip operator"))

(defun make-operator-skip (observable count)
  (let ((op (make-instance 'operator-skip
		 :observable observable
		 :count count )))
    (setf (on-next op)
	  #'(lambda (x)
	      (if (< (current-count op) (count-num op))
		(incf (current-count op))
	  	(funcall (on-next (observer op)) x) )))
    (setf (on-error op)
	  #'(lambda (x)
	      (funcall (on-error (observer op))) ))
    (setf (on-completed op)
	  #'(lambda ()
	      (funcall (on-completed (observer op))) ))
    op ))


(defmethod subscribe ((op operator-skip) observer)
  (setf (observer op) observer)
  (subscribe (observable op) op) )

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
