(in-package :cl-user)
(defpackage cl-reex.observable.start
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed )
  (:import-from :cl-reex.observable
        :observable
        :observable-object
        :dispose
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:export :observable-start) )


(in-package :cl-reex.observable.start)


(defclass observable-start-object (observable-object)
  ((exprs :initarg :exprs
          :accessor exprs )
   (thread :initarg :thread
           :accessor thread )
   (result :initarg :result
           :accessor result )))

(defun make-observable-start-object (exprs)
  (make-instance 'observable-start-object
                 :exprs exprs ))

(defclass disposable-observable-start-object ()
  ((object :initarg :object
           :accessor object )
   (observer :initarg :observer
             :accessor observer )))

(defmethod dispose ((dis-obj disposable-observable-start-object))
  (let* ((start-obj (object dis-obj))
         (thread (thread start-obj)) )
    (when (and (not (null thread))
               (bt:thread-alive-p thread) )
      (when (not (eq thread (bt:current-thread)))
        (bt:destroy-thread thread) ))
    (setf (thread start-obj) nil) ))

(defmethod subscribe ((obs observable-start-object) observer)
  (if (slot-boundp obs 'result)
      (progn
        (on-next observer (result obs))
        (on-completed observer)
        (set-completed obs) )
      (let ((thread (bt:make-thread
                     (lambda ()
                       (dolist (expr (exprs obs))
                         (setf (result obs) (eval expr) ))
                       (on-next observer (result obs))
                       (on-completed observer) 
                       (set-completed obs) ))))
        (setf (thread obs) thread) ))
  (make-instance 'disposable-observable-start-object
                 :object obs
                 :observer observer ))


(defmacro observable-start (&rest exprs)
  (make-observable-start-object exprs) )

