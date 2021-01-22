(in-package :cl-user)
(defpackage cl-reex.operator.reduce
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed)
  (:import-from :cl-reex.observable
        :observable
        :dispose
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe)
  (:import-from :cl-reex.macro.operator-table
        :set-function-like-operator-with-init-value )
  (:import-from :cl-reex.error-conditions
        :sequence-contains-no-elements-error )
  (:import-from :cl-reex.operator
        :operator )
  (:export :operator-reduce
        :reduce
        :make-operator-reduce))

(in-package :cl-reex.operator.reduce)


(defclass operator-reduce (operator)
  ((calc :initarg :calc
         :accessor calc )
   (acc :initarg :acc
        :accessor acc) )
  (:documentation "Reduce operator"))

(defun make-operator-reduce (observable calc &optional initial-value)
  (if (null initial-value)
      (make-instance 'operator-reduce
                     :observable observable
                     :calc calc )
      (make-instance 'operator-reduce
                     :observable observable
                     :calc calc
                     :acc initial-value )))


(defmethod on-next ((op operator-reduce) x)
  (when (is-active op)
    (if (slot-boundp op 'acc)
        (setf (acc op)
              (funcall (calc op) (acc op) x) )
        (setf (acc op) x) )))

(defmethod on-error ((op operator-reduce) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-reduce))
  (when (is-active op)
    (if (slot-boundp op 'acc)
        (progn
          (on-next (observer op) (acc op))
          (on-completed (observer op))
          (set-completed op) )
        (let ((err (make-condition 'sequence-contains-no-elements-error)))
          (on-error (observer op) err)
          (set-error op) ))))

(set-function-like-operator-with-init-value 'reduce 'make-operator-reduce)

