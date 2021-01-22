(in-package :cl-user)
(defpackage cl-reex.operator.zip
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed )
  (:import-from :cl-reex.observable
        :observable
        :dispose
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:import-from :cl-reex.macro.operator-table
        :set-one-arg-operator )
  (:import-from :cl-reex.queue
           :make-queue
           :enqueue
           :dequeue
           :is-empty
           :elements-count )
  (:import-from :cl-reex.operator
        :operator
        :cleanup-operator )
  (:export :operator-zip
        :zip
        :make-operator-zip ))

(in-package :cl-reex.operator.zip)


(defclass operator-zip (operator)
  ((other :initarg :other
          :accessor other )
   (other-subscription :initarg :other-subscription
                       :accessor other-subscription )
   (source-item-queue :initarg :source-item-queue
                      :initform (make-queue)
                      :accessor source-item-queue )
   (other-item-queue :initarg :other-item-queue
                     :initform (make-queue)
                     :accessor other-item-queue ))
  (:documentation "Zip operator"))

(defun make-operator-zip (observable other)
  (make-instance 'operator-zip
                 :observable observable
                 :other other ))


(defmethod on-next ((op operator-zip) x)
  (when (is-active op)
    (if (is-empty (other-item-queue op))
        (enqueue (source-item-queue op) x)
        (on-next (observer op) (list x (dequeue (other-item-queue op)))) )))

(defmethod on-error ((op operator-zip) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-zip))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))

(defmethod subscribe ((op operator-zip) observer)
  (let ((other-observer (make-observer
                         (on-next (x)
                                  (when (is-active op)
                                    (if (is-empty (source-item-queue op))
                                        (enqueue (other-item-queue op) x)
                                        (on-next (observer op) (list (dequeue (source-item-queue op)) x)) )))
                         (on-error (x)
                                   (when (is-active op)
                                     (on-error (observer op) x)
                                     (set-error op) ))
                         (on-completed ()
                                       (when (is-active op)
                                         (set-completed op)
                                         (on-completed observer op) )))))
    (setf (other-subscription op) (subscribe (other op) other-observer)) )
  (call-next-method) )


(defmethod cleanup-operator ((op operator-zip))
  (when (slot-boundp op 'other-subscription)
    (dispose (other-subscription op))
;    (slot-unbound 'operator-zip op 'other-subscription)
    ))


(set-one-arg-operator 'zip 'make-operator-zip)

