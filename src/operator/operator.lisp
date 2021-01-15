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

(defmethod subscribe ((op operator) observer)
  (setf (observer op) observer)
  (when (slot-boundp op 'subscription)
    (dispose (subscription op)) )
  (set-active op)
  (setf (subscription op) (subscribe (observable op) op)) )
