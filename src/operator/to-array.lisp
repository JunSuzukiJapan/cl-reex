(in-package :cl-user)
(defpackage cl-reex.operator.to-array
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
  (:export :operator-to-array
        :to-array
        :make-operator-to-array ))

(in-package :cl-reex.operator.to-array)


(defclass operator-to-array (operator)
  ((items :initarg :items
          :initform nil
          :accessor items ))
  (:documentation "To-Array operator") )

(defun make-operator-to-array (observable)
  (make-instance 'operator-to-array
                 :observable observable ))

;;
;; on-next, on-error & on-completed
;;
(defmethod on-next ((op operator-to-array) x)
  (when (is-active op)
    (push x (items op)) ))

(defmethod on-error ((op operator-to-array) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-to-array))
  (when (is-active op)
    (let* ((lst (reverse (items op)))
           (ary (make-array (length lst)
                            :initial-contents lst )))
    (on-next (observer op) ary))
    (on-completed (observer op))
    (set-completed op) ))

;;
;; subscribe
;;
(defmethod subscribe ((op operator-to-array) x)
  (setf (items op) nil)
  (call-next-method) )

;;
;; set to operator-table
;;
(set-zero-arg-operator 'to-array 'make-operator-to-array)

