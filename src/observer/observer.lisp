(in-package :cl-user)
(defpackage cl-reex.observer
  (:use :cl)
  (:import-from :cl-reex.observable
		:on-next
		:on-error
		:on-completed)
  (:export :observer
	   :make-observer))
(in-package :cl-reex.observer)

;; body


(defclass observer ()
  ((on-next :initarg :on-next
	    :initform (lambda (x) nil)
	    :accessor on-next)
   (on-error :initarg :on-error
	     :initform (lambda (x) nil)
	     :accessor on-error)
   (on-completed :initarg :on-completed
		 :initform (lambda () nil)
		 :accessor on-completed) )
  (:documentation "Observer"))


(defun make-observer (on-next on-error on-completed)
  (make-instance 'observer
		 :on-next on-next
		 :on-error on-error
		 :on-completed on-completed))








#|
(defvar observer)
(setq observer (rx:make-observer
		#'(lambda (x) (print x))
		#'(lambda (x) (format t "error: ~S" x))
		#'(lambda () (print "completed")) ))
|#



