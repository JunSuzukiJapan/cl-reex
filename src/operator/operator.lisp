(in-package :cl-user)
(defpackage cl-reex.operator
  (:use :cl)
  (:import-from :cl-reex.observable
        :observable
        :get-on-error
        :dispose
        :disposable-do-nothing
        :subscribe)
  (:import-from :cl-reex.observer
        :observer)
  (:export :operator
        :predicate
        :func))

(in-package :cl-reex.operator)

;; body

(defclass operator (observer)
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
  (setf (subscription op) (subscribe (observable op) op)) )
