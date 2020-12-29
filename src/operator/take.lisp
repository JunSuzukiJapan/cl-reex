(in-package :cl-user)
(defpackage cl-reex.operator.take
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
		:take )
  (:import-from :cl-reex.operator
		:operator
		:observable
		:predicate)
  (:export :operator-take
	   :make-operator-take))

(in-package :cl-reex.operator.take)


(defclass operator-take (operator)
  ((observable :initarg :observable
	       :accessor observable)
   (count :initarg :count
	  :accessor count-num)
   (current-count :initarg :current-count
		  :initform 0
		  :accessor current-count)
   (observer :initarg :observer
	     :accessor observer) )
  (:documentation "Take operator"))

(defun make-operator-take (observable count)
  (let ((op (make-instance 'operator-take
		 :observable observable
		 :count count )))
    (setf (on-next op)
	  #'(lambda (x)
	      (when (< (current-count op) (count-num op))
		(incf (current-count op))
	  	(funcall (on-next (observer op)) x)
		(when (>= (current-count op) (count-num op))
		  (funcall (on-completed (observer op))) ))))
    (setf (on-error op)
	  #'(lambda (x)
	      (funcall (on-error (observer op))) ))
    (setf (on-completed op) ;; do nothing
	  #'(lambda () ))
    op ))


(defmethod subscribe ((op operator-take) observer)
  (setf (observer op) observer)
  (setf (current-count op) 0)
  (subscribe (observable op) op) )

;;
;; in Let*-expr
;;    make definition like below
;;
;; (let* (...
;;        !! from HERE !!
;;        (var-name (rx:make-operator-take
;;                       temp-observable
;;                       #'(lambda (x) (evenp x)) ))
;;        !! to HERE   !!
;;        ...)
;;    ...)
;;

(set-operator-expander 'take
    #'(lambda (x var-name temp-observable)
	`(,var-name
	  (make-operator-take
	   ,temp-observable
	   ,(cadr x) ))))
