(in-package :cl-user)
(defpackage cl-reex.subject.subject
  (:use :cl)
  (:import-from :cl-reex.observer
 		:observer
		:on-next
		:on-error
		:on-completed)
  (:import-from :cl-reex.observable
		:observable
		:subscribe
		:dispose)
  (:export :subject
	   :make-subject))

(in-package :cl-reex.subject.subject)

(defclass subject (observer)
  ((observers :initarg :observers
	      :initform nil
	      :accessor observers )))

(defun make-subject ()
  (let ((sub (make-instance 'subject)))
    (setf (on-next sub)
	  #'(lambda (x)
	      (dolist (observer (observers sub))
	  	(funcall (on-next observer) x) )))
    (setf (on-error sub)
	  #'(lambda (x)
	      (dolist (observer (observers sub))
		(funcall (on-error observer) x) )))
    (setf (on-completed sub)
	  #'(lambda ()
	      (dolist (observer (observers sub))
		(funcall (on-completed observer)) )))
    sub ))

;;
;; Dispose
;;
(defclass disposable-subject ()
  ((subject :initarg :subject
	    :accessor subject)
   (observer :initarg :observer
	     :accessor observer) ))

(defmethod dispose ((dis-sub disposable-subject))
  (delete (observer dis-sub) (observers dis-sub)) )

;;
;; Subscribe
;;
(defmethod subscribe ((sub subject) observer)
  (push observer (observers sub))
  (make-instance 'disposable-subject
		 :subject sub
		 :observer observer ))

