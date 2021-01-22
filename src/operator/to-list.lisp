(in-package :cl-user)
(defpackage cl-reex.operator.to-list
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
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
        :set-zero-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :cleanup-operator )
  (:export :operator-to-list
        :to-list
        :make-operator-to-list ))

(in-package :cl-reex.operator.to-list)


(defclass operator-to-list (operator)
  ((items :initarg :items
          :initform nil
          :accessor items ))
  (:documentation "To-List operator") )

(defun make-operator-to-list (observable)
  (make-instance 'operator-to-list
                 :observable observable ))

;;
;; on-next, on-error & on-completed
;;
(defmethod on-next ((op operator-to-list) x)
  (when (is-active op)
    (push x (items op)) ))

(defmethod on-error ((op operator-to-list) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-to-list))
  (when (is-active op)
    (on-next (observer op) (reverse (items op)))
    (on-completed (observer op))
    (set-completed op) ))

;;
;; subscribe
;;
(defmethod subscribe ((op operator-to-list) x)
  (setf (items op) nil)
  (call-next-method) )

;;
;; set to operator-table
;;
(set-zero-arg-operator 'to-list 'make-operator-to-list)

