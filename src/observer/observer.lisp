(in-package :cl-user)
(defpackage cl-reex.observer
  (:use :cl)
  (:export :observer
           :make-observer
           :on-next
           :on-error
           :on-completed
           :set-on-next
           :set-on-error
           :set-on-completed ))
(in-package :cl-reex.observer)

;; body


(defclass observer ()
  ((on-next :initarg :on-next
            :initform (lambda (x) (declare (ignore x)) nil)
            :reader get-on-next
            :writer set-on-next )
   (on-error :initarg :on-error
             :initform (lambda (x) (declare (ignore x)) nil)
             :reader get-on-error
             :writer set-on-error )
   (on-completed :initarg :on-completed
                 :initform (lambda () nil)
                 :reader get-on-completed
                 :writer set-on-completed ))
  (:documentation "Observer"))

(defgeneric on-next (obj value))
(defgeneric on-error (obj err))
(defgeneric on-completed (obj))

(defmethod on-next ((obs observer) value)
  (funcall (get-on-next obs) value) )


(defmethod on-error ((obs observer) value)
  (funcall (get-on-error obs) value) )

(defmethod on-completed ((obs observer))
  (funcall (get-on-completed obs)) )

(defun make-observer (on-next on-error on-completed)
  (make-instance 'observer
                 :on-next on-next
                 :on-error on-error
                 :on-completed on-completed))
