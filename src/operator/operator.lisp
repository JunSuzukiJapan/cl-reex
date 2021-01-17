(in-package :cl-user)
(defpackage cl-reex.operator
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer )
  (:import-from :cl-reex.observable
        :observable
        :observable-object
        :set-active
        :dispose
        :disposable-do-nothing
        :subscribe)
  (:export :operator
        :predicate
        :cleanup-operator
        :func
        :subscription ))

(in-package :cl-reex.operator)

;; body

(defclass operator (observable-object)
  ((observable :initarg :observable
               :accessor observable)
   (observer :initarg :observer
             :accessor observer)
   (subscription :initarg :subscription
                 :accessor subscription) ))

(defclass disposable-operator (disposable-do-nothing)
  ((operator :initarg :operator
             :accessor operator)) )

(defgeneric cleanup-operator (op))

(defmethod cleanup-operator ((op operator))
  (when (slot-boundp op 'subscription)
    (dispose (subscription op)) ))

(defmethod dispose ((disposable disposable-operator))
  (cleanup-operator (operator disposable)) )


(defmethod subscribe ((op operator) observer)
  (setf (observer op) observer)
  (when (slot-boundp op 'subscription)
    (dispose (subscription op)) )
  (set-active op)
  (setf (subscription op) (subscribe (observable op) op))
  (make-instance 'disposable-operator
         :observable op
         :observer observer
         :operator op ))
