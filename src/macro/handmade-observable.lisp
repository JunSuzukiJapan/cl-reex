(in-package :cl-user)
(defpackage cl-reex.macro.handmade-observable
  (:use :cl)
  (:import-from :cl-reex.observable
 		:subscribe
		:observable
		:observable-object
		:is-active
		:observable-state
		:active
		:error
		:completed
		:disposed
		:dispose
		:get-on-next
		:get-on-error
		:get-on-completed
 		:observable-from
 		:on-next
 		:on-error
 		:on-completed
		:disposable-do-nothing)
  (:import-from :cl-reex.observer
 		:observer )
  (:export :handmade-observable) )

(in-package :cl-reex.macro.handmade-observable)


(defclass handmade-observable-object (observable-object)
    ((source :initarg :source
	     :accessor source) ))

(defmethod subscribe ((observable handmade-observable-object) observer)
  (dolist (message (source observable))
    (let ((on-next (get-on-next observer))
	  (on-error (get-on-error observer))
	  (on-completed (get-on-completed observer)) )
      (case (car message)
	;; on-next
	('on-next
	 (when (is-active observable)
	   (funcall on-next (cadr message)) ))
	;; on-error
	('on-error
	 (when (is-active observable)
	   (setf (state observable) 'error)
	   (funcall on-error (cadr message)) ))
	;; on-completed
	('on-completed
	 (when (is-active observable)
	   (setf (state observable) 'completed)
	   (funcall on-completed) )))))
  (make-instance 'disposable-do-nothing
		 :observable observable
		 :observer observer ) )

(defmacro handmade-observable (&rest body)
  `(make-instance 'handmade-observable-object
		  :source ',body ))
