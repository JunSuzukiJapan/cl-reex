(in-package :cl-user)
(defpackage cl-reex.observer
  (:use :cl)
  (:import-from :cl-reex.observable
		:on-next
		:on-error
		:on-completed
		:get-on-next
		:set-on-next
		:get-on-error
		:set-on-error
		:get-on-completed
		:set-on-completed
		:make-observer)
  (:export :observer))
(in-package :cl-reex.observer)

;; body


(defclass observer ()
  ((on-next :initarg :on-next
	    :initform (lambda (x) nil)
	    :reader get-on-next
	    :writer set-on-next )
   (on-error :initarg :on-error
	     :initform (lambda (x) nil)
	     :reader get-on-error
	     :writer set-on-error )
   (on-completed :initarg :on-completed
		 :initform (lambda () nil)
		 :reader get-on-completed
		 :writer set-on-completed ))
  (:documentation "Observer"))


(defun make-observer (on-next on-error on-completed)
  (make-instance 'observer
		 :on-next on-next
		 :on-error on-error
		 :on-completed on-completed))

