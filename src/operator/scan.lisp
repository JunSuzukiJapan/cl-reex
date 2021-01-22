(in-package :cl-user)
(defpackage cl-reex.operator.scan
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
  (:export :operator-scan
        :scan
        :make-operator-scan))

(in-package :cl-reex.operator.scan)


(defclass operator-scan (operator)
  ((calc :initarg :calc
         :accessor calc )
   (acc :initarg :acc
        :accessor acc) )
  (:documentation "Scan operator"))

(defun make-operator-scan (observable calc &optional initial-value)
  (if (null initial-value)
      (make-instance 'operator-scan
                     :observable observable
                     :calc calc )
      (make-instance 'operator-scan
                     :observable observable
                     :calc calc
                     :acc initial-value )))


(defmethod on-next ((op operator-scan) x)
  (when (is-active op)
    (if (slot-boundp op 'acc)
        (setf (acc op)
              (funcall (calc op) (acc op) x) )
        (setf (acc op) x) )
    (on-next (observer op) (acc op)) ))

(defmethod on-error ((op operator-scan) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-scan))
  (when (is-active op)
    (if (slot-boundp op 'acc)
        (progn
          (on-completed (observer op))
          (set-completed op) )
        (let ((err (make-condition 'sequence-contains-no-elements-error)))
          (set-error op)
          (on-error (observer op) err) ))))

(set-function-like-operator-with-init-value 'scan 'make-operator-scan)

