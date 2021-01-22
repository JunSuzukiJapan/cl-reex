(in-package :cl-user)
(defpackage cl-reex.operator.repeat
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
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator
        :predicate)
  (:export :operator-repeat
        :repeat
        :make-operator-repeat))

(in-package :cl-reex.operator.repeat)


(defclass operator-repeat (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Repeat operator"))

(defun make-operator-repeat (observable count)
  (make-instance 'operator-repeat
                 :observable observable
                 :count count ))


(defmethod on-next ((op operator-repeat) x)
  (when (is-active op)
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-repeat) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-repeat))
  (when (is-active op)
    (incf (current-count op))
    (if (>= (current-count op) (count-num op))
        (progn
          (on-completed (observer op))
          (set-completed op) )
        (subscribe (observable op) op) )))

(defmethod subscribe ((op operator-repeat) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (current-count op) 0)
    (call-next-method) ))

(set-one-arg-operator 'repeat 'make-operator-repeat)

