(in-package :cl-user)
(defpackage cl-reex.operator.merge
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
        :set-rest-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :cleanup-operator
        :subscription )
  (:export :operator-merge
        :merge
        :make-operator-merge ))

(in-package :cl-reex.operator.merge)


(defclass operator-merge (operator)
  ((sources :initarg :sources
            :initform nil
            :accessor sources )
   (source-subscription-pairs :initarg :pairs
                              :initform nil
                              :accessor pairs ))
  (:documentation "Merge operator") )

(defun make-operator-merge (observable &rest sources)
  (make-instance 'operator-merge
                 :observable observable
                 :sources sources ))

(defmethod cleanup-operator ((op operator-merge))
  (dolist (pair (pairs op))
    (dispose (cdr pair)) )
  (setf (pairs op) nil)
  (call-next-method) )


(defmethod on-next ((op operator-merge) x)
  (when (is-active op)
    (on-next (observer op) x) ))

(defmethod on-error ((op operator-merge) x)
  (when (is-active op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-merge))
  (when (is-active op)
    (on-completed (observer op))
    (set-completed op) ))


(defmethod subscribe ((op operator-merge) observer)
  (declare (ignore observer))

  ;; clear old subscriptions, if exists
  (set-disposed op)
  (cleanup-operator op)

  ;; subscribe again
  (let ((result (call-next-method)))
    (dolist (source (sources op))
      (let* ((observer (make-observer
                        ;; on-next
                        (on-next (x)
                                 (when (is-active op)
                                   (on-next (observer op) x) ))
                        ;; on-error
                        (on-error (x)
                                  (when (is-active op)
                                    (on-error (observer op) x)
                                    (set-error op) ))
                        ;; on-completed
                        (on-completed ()
                                      (when (is-active op)
                                        (on-completed (observer op)))
                                        (set-completed op) )))
             (sub (subscribe source observer)) )
        (push (cons source sub) (pairs op)) ))

    result ))

(set-rest-arg-operator 'merge 'make-operator-merge)

