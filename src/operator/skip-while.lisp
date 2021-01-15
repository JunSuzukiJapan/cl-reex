(in-package :cl-user)
(defpackage cl-reex.operator.skip-while
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
  (:export :operator-skip-while
        :skip-while
        :make-operator-skip-while))

(in-package :cl-reex.operator.skip-while)


(defclass operator-skip-while (operator)
  ((predicate :initarg :predicate
              :accessor predicate )
   (completed :initarg :completed
              :initform nil
              :accessor completed ))
  (:documentation "Skip-While operator"))

(defun make-operator-skip-while (observable predicate)
  (make-instance 'operator-skip-while
                 :observable observable
                 :predicate predicate ))


(defmethod on-next ((op operator-skip-while) x)
  (if (completed op)
      (on-next (observer op) x)
      (when (not (funcall (predicate op) x))
        (setf (completed op) t)
        (on-next (observer op) x) )))

(defmethod on-error ((op operator-skip-while) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-skip-while))
  (when (is-active op)
    (set-completed op)
    (on-completed (observer op)) ))

(defmethod subscribe ((op operator-skip-while) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (completed op) nil)
    (call-next-method) ))

(set-function-like-operator 'skip-while 'make-operator-skip-while)

