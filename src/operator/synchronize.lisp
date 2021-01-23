(in-package :cl-user)
(defpackage cl-reex.operator.synchronize
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :on-next
        :on-error
        :on-completed )
  (:import-from :cl-reex.observable
        :observable
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :dispose
        :subscribe )
  (:import-from :cl-reex.macro.operator-table
        :set-zero-or-one-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :predicate )
  (:export :operator-synchronize
        :synchronize
        :make-operator-synchronize ))

(in-package :cl-reex.operator.synchronize)


(defclass operator-synchronize (operator)
  ((gate :initarg :gate
         :accessor gate ))
  (:documentation "Synchronize operator"))

(defun make-operator-synchronize (observable &optional gate)
  (when (null gate)
    (setf gate (bt:make-lock)) )
  (make-instance 'operator-synchronize
                 :observable observable
                 :gate gate ))


(defmethod on-next ((op operator-synchronize) x)
  (when (is-active op)
    (bt:with-lock-held ((gate op))
      (on-next (observer op) x) )))

(defmethod on-error ((op operator-synchronize) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-synchronize))
  (when (is-active op)
    (bt:with-lock-held ((gate op))
      (on-completed (observer op))
      (set-completed op) )))


(set-zero-or-one-arg-operator 'synchronize 'make-operator-synchronize)

