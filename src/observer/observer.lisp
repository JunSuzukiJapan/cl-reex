(in-package :cl-user)
(defpackage cl-reex.observer
  (:use :cl)
  (:export :observer
           :make-observer
           :do-nothing-no-arg
           :do-nothing-one-arg
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

(defun do-nothing-no-arg ())
(defun do-nothing-one-arg (x)
  (declare (ignore x)) )

(defmacro make-observer (&rest args)
  (let ((on-next '(on-next (x) (do-nothing-one-arg x)))
        (on-error '(on-error (x) (do-nothing-one-arg x)))
        (on-completed '(on-completed () (do-nothing-no-arg))) )
    (dolist (arg args)
      (case (car arg)
        ((on-next)
         (setf on-next arg) )
        ((on-error)
         (setf on-error arg) )
        ((on-completed)
         (setf on-completed arg) )
        (t
         (error (format nil "illegal identifier '~A'. need 'on-next', 'on-error' or 'on-completed'" (car arg)))) ))

  `(make-instance 'observer
                  :on-next #'(lambda ,(cadr on-next) ,@(cddr on-next))
                  :on-error #'(lambda ,(cadr on-error) ,@(cddr on-error))
                  :on-completed #'(lambda ,(cadr on-completed) ,@(cddr on-completed)) )))
