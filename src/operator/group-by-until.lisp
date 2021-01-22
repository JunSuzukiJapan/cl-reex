(in-package :cl-user)
(defpackage cl-reex.operator.group-by-until
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
        :set-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe )
  (:import-from :cl-reex.subject.subject
        :as-observable )
  (:import-from :cl-reex.subject.replay-subject
        :replay-subject 
        :make-replay-subject )
  (:import-from :cl-reex.macro.operator-table
        :set-one-arg-two-body-function-like-operator )
  (:import-from :cl-reex.operator
        :operator )
  (:import-from :cl-reex.operator.group-by
        :operator-group-by
        :group-by
        :table
        :key-generator
        :key-subject
        :get-key )
  (:export :operator-group-by-until
        :group-by-until
        :make-operator-group-by-until ))

(in-package :cl-reex.operator.group-by-until)

;; class operator-group-by-until
(defclass operator-group-by-until (operator-group-by)
  ((until-generator :initarg :until-generator
                    :accessor until-generator ))
  (:documentation "Group-By-Until operator"))

(defun make-operator-group-by-until (observable key-generator until-generator)
  (make-instance 'operator-group-by-until
                 :observable observable
                 :key-generator key-generator
                 :until-generator until-generator ))

;; class key-subject
(defclass key-until-subject (key-subject)
  ((until :initarg :until
          :accessor until )))

(defun make-key-until-subject (key until)
  (let ((sub (make-instance 'key-until-subject
                            :key key
                            :until until )))
    (set-active sub)
    sub ))

;;
;; on-next, on-error, on-completed
;;
(defmethod on-next ((op operator-group-by-until) x)
  (when (is-active op)
    (let* ((key (funcall (key-generator op) x))
           (tbl (table op))
           (subject (gethash key tbl)) )
      (when (null subject)
        (let* ((until (funcall (until-generator op) x)))
          (setf subject (make-key-until-subject key until))
          (subscribe until (make-observer
                            (on-next (x)
                                     (declare (ignore x))
                                     (on-completed subject) )
                            (on-error (x)
                                      (on-error subject x) )
                            (on-completed ()
                                          (on-completed subject) ))) )
        (setf (gethash key tbl) subject)
        (on-next (observer op) (as-observable subject)) )
      (on-next subject x) )))

(defmethod on-error ((op operator-group-by-until) x)
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
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-group-by-until))
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
    (on-completed (observer op))
    (set-completed op) ))

;; set to operator-table
(set-one-arg-two-body-function-like-operator 'group-by-until 'make-operator-group-by-until)

