(in-package :cl-user)
(defpackage cl-reex.operator.take
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
  (:export :operator-take
        :take
        :make-operator-take))

(in-package :cl-reex.operator.take)


(defclass operator-take (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Take operator"))

(defun make-operator-take (observable count)
  (make-instance 'operator-take
                 :observable observable
                 :count count ))


(defmethod on-next ((op operator-take) x)
  (when (is-active op)
    (when (< (current-count op) (count-num op))
      (incf (current-count op))
      (on-next (observer op) x)
      (when (>= (current-count op) (count-num op))
        (on-completed (observer op)) ))))

(defmethod on-error ((op operator-take) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-take))
  (when (is-active op)
    (set-completed op)
    ;; do nothing
    ))

(defmethod subscribe ((op operator-take) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (current-count op) 0)
    (call-next-method) ))

(set-one-arg-operator 'take 'make-operator-take)

