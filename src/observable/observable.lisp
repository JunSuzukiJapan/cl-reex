(in-package :cl-user)
(defpackage cl-reex.observable
  (:use :cl)
  (:export :subscribe
	   :on-next
	   :on-error
	   :on-completed
	   :observable-from
 	   :observable-state
	   :dispose ))

(in-package :cl-reex.observable)

;; body

(defgeneric on-next (obj))
(defgeneric on-error (obj))
(defgeneric on-completed (obj))

(defgeneric subscribe (observable observer))
(defgeneric observable-from (source))

(defgeneric dispose (obj))

(deftype observable-state () '(active error completed))

(defclass observable-list ()
  ((src-list :initarg :src-list
	     :initform nil
	     :accessor src-list) )
  (:documentation "Observable from List") )

(defclass disposable-observable-list ()
  ((observable :initarg :observable
	       :accessor observable)
   (observer :initarg :observer
	     :accessor observer) ))

(defmethod subscribe ((lst observable-list) observer)
  (dolist (x (src-list lst))
    (funcall (on-next observer) x) )
  (funcall (on-completed observer))
  (make-instance 'disposable-observable-list
		 :observable lst
		 :observer observer ))

(defmethod dispose ((dis-lst disposable-observable-list)))

(defmethod observable-from ((source list))
  (make-instance 'observable-list :src-list source))

;(defmethod observable-from ((source string)))
;(defmethod observable-from ((source array)))
;(defmethod observable-from ((source stream)))
;(defmethod observable-from ((source fundamental-input-stream)))
