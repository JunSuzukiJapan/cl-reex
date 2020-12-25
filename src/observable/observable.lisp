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

;;
;; observable from list
;;
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

;;
;; observable from array
;;
;(defmethod observable-from ((source array)))
(defclass observable-array ()
  ((source :initarg :source
	   :initform #()
	   :accessor source)) )

(defclass disposable-observable-array ()
  ((observable :initarg :observable
	       :accessor observable)
   (observer :initarg :observer
	     :accessor observer) ))

(defmethod subscribe ((ary observable-array) observer)
  (loop for item across (source ary)
     do (funcall (on-next observer) item) )
  (funcall (on-completed observer))
  (make-instance 'disposable-observable-array
		 :observable ary
		 :observer observer ))

(defmethod dispose ((dis-ary disposable-observable-array)))

(defmethod observable-from ((source array))
  (make-instance 'observable-array :source source) )



;(defmethod observable-from ((source string)))
;(defmethod observable-from ((source stream)))
;(defmethod observable-from ((source fundamental-input-stream)))



;(defun observable-range (from count))
