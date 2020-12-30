(in-package :cl-user)
(defpackage cl-reex.subject.subject
  (:use :cl)
  (:import-from :cl-reex.observable
		:observable
		:on-next
		:on-error
		:on-completed
		:get-on-next
		:set-on-next
		:get-on-error
		:set-on-error
		:get-on-completed
		:set-on-completed
		:subscribe
		:dispose)
  (:import-from :cl-reex.observer
 		:observer)
  (:export :subject
	   :make-subject))

(in-package :cl-reex.subject.subject)

(defclass subject (observer)
  ((observers :initarg :observers
	      :initform nil
	      :accessor observers )))

(defun make-subject ()
  (let ((sub (make-instance 'subject)))
    (set-on-next
	  #'(lambda (x)
	      (dolist (observer (observers sub))
	  	(funcall (get-on-next observer) x) ))
	  sub )
    (set-on-error
	  #'(lambda (x)
	      (dolist (observer (observers sub))
		(funcall (get-on-error observer) x) ))
	  sub )
    (set-on-completed
	  #'(lambda ()
	      (dolist (observer (observers sub))
		(funcall (get-on-completed observer)) ))
	  sub )
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
  (let ((deleted (delete (observer dis-sub) (observers (subject dis-sub)))))
    (setf (observers (subject dis-sub)) deleted) ))

;;
;; Subscribe
;;
(defmethod subscribe ((sub subject) observer)
  (push observer (observers sub))
  (make-instance 'disposable-subject
		 :subject sub
		 :observer observer ))

;;
;; on-next, on-error & on-completed
;;
(defmethod on-next ((sub subject) item)
  (funcall (get-on-next sub) item) )

(defmethod on-error ((sub subject) condition)
  (funcall (get-on-error sub) condition) )

(defmethod on-completed ((sub subject))
  (funcall (get-on-completed sub)) )

