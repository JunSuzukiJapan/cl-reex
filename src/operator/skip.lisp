(in-package :cl-user)
(defpackage cl-reex.operator.skip
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
  (:export :operator-skip
        :skip
        :make-operator-skip))

(in-package :cl-reex.operator.skip)


(defclass operator-skip (operator)
  ((count :initarg :count
          :accessor count-num)
   (current-count :initarg :current-count
                  :initform 0
                  :accessor current-count) )
  (:documentation "Skip operator"))

(defun make-operator-skip (observable count)
  (make-instance 'operator-skip
                 :observable observable
                 :count count ))


(defmethod on-next ((op operator-skip) x)
  (when (is-active op)
    (if (< (current-count op) (count-num op))
        (incf (current-count op))
        (on-next (observer op) x) )))

(defmethod on-error ((op operator-skip) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-skip))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))

(defmethod subscribe ((op operator-skip) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable op
                                   :observer observer )))))
    (setf (current-count op) 0)
    (call-next-method) ))

(set-one-arg-operator 'skip 'make-operator-skip)

