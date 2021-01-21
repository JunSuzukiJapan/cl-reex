(in-package :cl-user)
(defpackage cl-reex.operator.group-by
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
        :set-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:import-from :cl-reex.subject.subject
        :subject
        :subject-as-observable-wrapper
        :disposable-subject-as-observable-wrapper
        :as-observable )
  (:import-from :cl-reex.subject.replay-subject
        :replay-subject
        :make-replay-subject )
  (:import-from :cl-reex.macro.operator-table
        :set-function-like-operator )
  (:import-from :cl-reex.operator
        :operator )
  (:export :operator-group-by
        :group-by
        :get-key
        :key-generator
        :table
        :make-key-subject
        :make-operator-group-by ))

(in-package :cl-reex.operator.group-by)

;; class operator-group-by
(defclass operator-group-by (operator)
  ((key-generator :initarg :key-generator
                  :accessor key-generator )
   (table :initarg :table
          :initform (make-hash-table)
          :accessor table ))
  (:documentation "Group-By operator"))

(defun make-operator-group-by (observable key-generator)
  (make-instance 'operator-group-by
                 :observable observable
                 :key-generator key-generator ))

;; class key-subject
(defclass key-subject (replay-subject)
  ((key :initarg :key
        :accessor key )))

(defun make-key-subject (key)
  (let ((sub (make-instance 'key-subject
                            :key key )))
    (set-active sub)
    sub ))

(defgeneric get-key (obj))

(defmethod get-key ((sub key-subject))
  (key sub) )

;;
;; as-observable
;;
(defclass subject-as-observable-wrapper-with-key (subject-as-observable-wrapper)
  nil )

(defmethod as-observable ((sub key-subject))
  (make-instance 'subject-as-observable-wrapper-with-key
                 :subject sub ))

(defmethod get-key ((wrapper subject-as-observable-wrapper-with-key))
  (key (subject wrapper)) )

;;
;; on-next, on-error, on-completed
;;
(defmethod on-next ((op operator-group-by) x)
  (when (is-active op)
    (let* ((key (funcall (key-generator op) x))
           (tbl (table op))
           (subject (gethash key tbl)) )
      (when (null subject)
        (setf subject (make-key-subject key))
        (setf (gethash key tbl) subject)
        (on-next (observer op) (as-observable subject)) )
      (on-next subject x) )))

(defmethod on-error ((op operator-group-by) x)
  (when (is-active op)
    (with-hash-table-iterator (my-iterator (table op))
      (loop
        (multiple-value-bind (entry-p key value)
            (my-iterator)
          (declare (ignore key))
          (if entry-p
              (when (is-active op)
                (on-error value x)
                (set-error value) )
              (return)))))
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-group-by))
  (when (is-active op)
    (with-hash-table-iterator (my-iterator (table op))
      (loop
        (multiple-value-bind (entry-p key value)
            (my-iterator)
          (declare (ignore key))
          (if entry-p
              (when (is-active op)
                (on-completed value)
                (set-completed value) )
              (return)))))
    (set-completed op)
    (on-completed (observer op)) ))

;; set to operator-table
(set-function-like-operator 'group-by 'make-operator-group-by)

