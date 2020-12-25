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
;; Util
;;
(defclass disposable-do-nothing ()
  ((observable :initarg :observable
	       :accessor observable)
   (observer :initarg :observer
	     :accessor observer) ))

(defmethod dispose ((observable disposable-do-nothing)))

;;
;; observable from list
;;
(defclass observable-list ()
  ((src-list :initarg :src-list
	     :initform nil
	     :accessor src-list) )
  (:documentation "Observable from List") )

(defmethod subscribe ((lst observable-list) observer)
  (dolist (x (src-list lst))
    (funcall (on-next observer) x) )
  (funcall (on-completed observer))
  (make-instance 'disposable-do-nothing
		 :observable lst
		 :observer observer ))

(defmethod observable-from ((source list))
  (make-instance 'observable-list :src-list source))

;;
;; observable from string
;;
(defclass observable-string ()
  ((source :initarg :source
	   :accessor source)))

(defmethod subscribe ((stream observable-string) observer)
  (let ((s (make-string-input-stream (source stream))))
    (do ((ch (read-char s nil) (read-char s nil)))
	((null ch))
	(funcall (on-next observer) ch) ))
  (funcall (on-completed observer))
  (make-instance 'disposable-do-nothing
		 :observable stream
		 :observer observer ))

(defmethod observable-from ((source string))
  (make-instance 'observable-string :source source) )


;;
;; observable from array
;;
(defclass observable-array ()
  ((source :initarg :source
	   :initform #()
	   :accessor source)) )

(defmethod subscribe ((ary observable-array) observer)
  (loop for item across (source ary)
     do (funcall (on-next observer) item) )
  (funcall (on-completed observer))
  (make-instance 'disposable-do-nothing
		 :observable ary
		 :observer observer ))

(defmethod observable-from ((source array))
  (make-instance 'observable-array :source source) )

;;
;; observable from stream
;;
(defclass observable-stream ()
  ((source :initarg :source
	   :accessor source)) )

(defmethod subscribe ((stream observable-stream) observer)
  (let ((strm (source stream)))
    (do (ch (read-char strm))
	(funcall (on-next observer) ch)))
  (funcall (on-completed observer))
  (make-instance 'disposable-do-nothing
		 :observable stream
		 :observer observer ))

(defmethod observalbe-from ((source stream))
  (make-instance 'observable-stream :source source) )



;(defmethod observable-from ((source fundamental-input-stream)))



;(defun observable-range (from count))
