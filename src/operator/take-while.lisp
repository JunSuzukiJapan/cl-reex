(in-package :cl-user)
(defpackage cl-reex.operator.take-while
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed)
  (:import-from :cl-reex.observable
        :observable
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :dispose
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-function-like-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-take-while
        :take-while
        :make-operator-take-while))

(in-package :cl-reex.operator.take-while)


(defclass operator-take-while (operator)
  ((predicate :initarg :predicate
              :accessor predicate )
   (completed :initarg :completed
              :initform nil
              :accessor completed ))
  (:documentation "Take-While operator"))

(defun make-operator-take-while (observable predicate)
  (make-instance 'operator-take-while
                 :observable observable
                 :predicate predicate ))


(defmethod on-next ((op operator-take-while) x)
  (when (and (is-active op)
             (not (completed op)) )
    (if (funcall (predicate op) x)
        (on-next (observer op) x)
        (progn
          (setf (completed op) t)
          (on-completed (observer op)) ))))

(defmethod on-error ((op operator-take-while) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-take-while))
  (when (is-active op)
    (set-completed op)
    ;; do nothing
    ))

(defmethod subscribe ((op operator-take-while) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (completed op) nil)
    (call-next-method) ))

(set-function-like-operator 'take-while 'make-operator-take-while)

