(in-package :cl-user)
(defpackage cl-reex.operator.skip-last
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
  (:export :operator-skip-last
        :skip-last
        :make-operator-skip-last))

(in-package :cl-reex.operator.skip-last)


(defclass operator-skip-last (operator)
  ((skip-count :initarg :skip-count
               :accessor skip-count )
   (stack :initarg :stack
          :initform nil
          :accessor stack ))
  (:documentation "Skip-Last operator"))

(defun make-operator-skip-last (observable count)
  (make-instance 'operator-skip-last
                 :observable observable
                 :skip-count count ))


(defmethod on-next ((op operator-skip-last) x)
  (when (is-active op)
    (push x (stack op)) ))

(defmethod on-error ((op operator-skip-last) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-skip-last))
  (when (is-active op)
    (let ((observer (observer op))
          (lst (stack op)) )
      ;; skip
      (dotimes (i (skip-count op))
        (pop lst) )
      (dolist (item (nreverse lst))
        (on-next observer item) ))
    (on-completed (observer op))
    (set-completed op) ))


(set-one-arg-operator 'skip-last 'make-operator-skip-last)

