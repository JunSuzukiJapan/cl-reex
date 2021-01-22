(in-package :cl-user)
(defpackage cl-reex.operator.combine-latest
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
  (:export :operator-combine-latest
        :combine-latest
        :make-operator-combine-latest ))

(in-package :cl-reex.operator.combine-latest)


(defclass operator-combine-latest (operator)
  ((other :initarg :other
          :accessor other )
   (other-subscription :initarg :other-subscription
                       :accessor other-subscription )
   (source-item :initarg :source-item
                :accessor source-item )
   (other-item :initarg :other-item
               :accessor other-item ))
  (:documentation "Combine-Latest operator"))

(defun make-operator-combine-latest (observable other)
  (make-instance 'operator-combine-latest
                 :observable observable
                 :other other ))


(defmethod on-next ((op operator-combine-latest) x)
  (when (is-active (observable op))
    (setf (source-item op) x)
    (when (slot-boundp op 'other-item)
      (on-next (observer op) (list x (other-item op))) )))

(defmethod on-error ((op operator-combine-latest) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-combine-latest))
  (when (is-active (observable op))
    (set-completed (observable op))
    (when (not (is-active (other op)))
      (on-completed (observer op)) )))

(defmethod subscribe ((op operator-combine-latest) observer)
  (let ((other-observer (make-observer
                         (on-next (x)
                                  (when (is-active (other op))
                                    (setf (other-item op) x)
                                    (when (slot-boundp op 'source-item)
                                      (on-next (observer op) (list (source-item op) x)) )))
                         (on-error (x)
                                   (when (is-active (other op))
                                     (on-error (observer op) x)
                                     (set-error op) ))
                         (on-completed ()
                                       (when (is-active (other op))
                                         (set-completed (other op))
                                         (when (not (is-active (observable op)))
                                           (on-completed (observer op)) ))))))
    (setf (other-subscription op) (subscribe (other op) other-observer)) )
  (call-next-method) )

(defmethod is-active ((op operator-combine-latest))
  (or (is-active (observable op))
      (is-active (other op)) ))

(defmethod cleanup-operator ((op operator-combine-latest))
  (when (slot-boundp op 'other-subscription)
    (dispose (other-subscription op))
;    (slot-unbound 'operator-combine-latest op 'other-subscription)
    ))

(set-one-arg-operator 'combine-latest 'make-operator-combine-latest)

