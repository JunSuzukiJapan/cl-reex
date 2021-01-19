(in-package :cl-user)
(defpackage cl-reex.operator.take-last
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
  (:import-from :cl-reex.fixed-size-queue
        :fixed-size-queue
        :make-fixed-size-queue
        :enqueue
        :dequeue
        :is-empty
        :elements-count
        :size )
  (:export :operator-take-last
        :take-last
        :make-operator-take-last))

(in-package :cl-reex.operator.take-last)


(defclass operator-take-last (operator)
  ((queue :initarg :queue
          :accessor queue ))
  (:documentation "Take-Last operator"))

(defun make-operator-take-last (observable count)
  (make-instance 'operator-take-last
                 :observable observable
                 :queue (make-fixed-size-queue count) ))


(defmethod on-next ((op operator-take-last) x)
  (when (is-active op)
    (enqueue (queue op) x) ))

(defmethod on-error ((op operator-take-last) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-take-last))
  (when (is-active op)
    (do ((queue (queue op))
         (observer (observer op)) )
        ((is-empty queue)
         (on-completed observer) )
      (let ((item (dequeue queue)))
        (on-next observer item) ))))

(set-one-arg-operator 'take-last 'make-operator-take-last)

