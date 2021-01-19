(in-package :cl-user)
(defpackage cl-reex.operator.default-if-empty
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
        :set-one-arg-operator)
  (:import-from :cl-reex.operator
        :operator )
  (:export :operator-default-if-empty
        :default-if-empty
        :make-operator-default-if-empty))

(in-package :cl-reex.operator.default-if-empty)


(defclass operator-default-if-empty (operator)
  ((default :initarg :default
            :accessor default )
   (has-some-item :initarg :has-some-item
                  :initform nil
                  :accessor has-some-item ))
  (:documentation "Default-If-Empty operator"))

(defun make-operator-default-if-empty (observable default)
  (make-instance 'operator-default-if-empty
                 :observable observable
                 :default default ))


(defmethod on-next ((op operator-default-if-empty) x)
  (when (is-active op)
    (setf (has-some-item op) t)
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-default-if-empty) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-default-if-empty))
  (when (is-active op)
    (when (not (has-some-item op))
      (on-next (observer op) (default op)) )
    (on-completed (observer op)) ))


(set-one-arg-operator 'default-if-empty 'make-operator-default-if-empty)

