(in-package :cl-user)
(defpackage cl-reex.operator.sequence-equalp
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
  (:export :operator-sequence-equalp
        :sequence-equalp
        :make-operator-sequence-equalp ))

(in-package :cl-reex.operator.sequence-equalp)


(defclass operator-sequence-equalp (operator)
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
  (:documentation "Sequence-Equalp operator"))

(defun make-operator-sequence-equalp (observable other)
  (make-instance 'operator-sequence-equalp
                 :observable observable
                 :other other ))


(defmethod on-next ((op operator-sequence-equalp) x)
  (when (is-active op)
    (if (is-empty (other-item-queue op))
        (enqueue (source-item-queue op) x)
        (let ((item (dequeue (other-item-queue op))))
          (unless (eq x item)
            (on-next (observer op) nil)
            (on-completed (observer op))
            (set-completed op) )))))

(defmethod on-error ((op operator-sequence-equalp) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-sequence-equalp))
  (when (is-active op)
    (if (and (is-empty (source-item-queue op))
             (is-empty (other-item-queue op)) )
        (on-next (observer op) t)
        (on-next (observer op) nil) )
    (on-completed (observer op))
    (set-completed op) ))

(defmethod subscribe ((op operator-sequence-equalp) observer)
  (let ((other-observer (make-observer
                         (on-next (x)
                                  (when (is-active op)
                                    (if (is-empty (source-item-queue op))
                                        (enqueue (other-item-queue op) x)
                                        (let ((item (dequeue (source-item-queue op))))
                                          (unless (eq item x)
                                            (on-next (observer op) nil)
                                            (on-completed (observer op))
                                            (set-completed op) )))))
                         (on-error (x)
                                   (when (is-active op)
                                     (set-error op)
                                     (on-error (observer op) x) ))
                         (on-completed ()
                                       (when (is-active op)
                                         (set-completed op)
                                         (on-completed observer op) )))))
    (setf (other-subscription op) (subscribe (other op) other-observer)) )
  (call-next-method) )


(defmethod cleanup-operator ((op operator-sequence-equalp))
  (when (slot-boundp op 'other-subscription)
    (dispose (other-subscription op))
;    (slot-unbound 'operator-sequence-equalp op 'other-subscription)
    ))


(set-one-arg-operator 'sequence-equalp 'make-operator-sequence-equalp)

