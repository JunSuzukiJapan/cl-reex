(in-package :cl-user)
(defpackage cl-reex.operator.amb
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
        :subscription )
  (:export :operator-amb
        :amb
        :make-operator-amb ))

(in-package :cl-reex.operator.amb)


(defclass operator-amb (operator)
  ((sources :initarg :sources
            :initform nil
            :accessor sources )
   (fastest :initarg :fastest
            :initform nil
            :accessor fastest )
   (source-subscription-pairs :initarg :pairs
                              :initform nil
                              :accessor pairs ))
  (:documentation "Amb operator") )

(defun make-operator-amb (observable &rest sources)
  (make-instance 'operator-amb
                 :observable observable
                 :sources sources ))

(defmethod clear-pairs-without ((op operator-amb) source)
  (let ((fastest))
    (dolist (pair (pairs op))
      (if (eq (car pair) source)
          (setf fastest pair)
        (dispose (cdr pair)) ))
    (setf (fastest op) fastest) )
  (setf (pairs op) nil) )
  

(defmethod on-next ((op operator-amb) x)
  (when (is-active op)
    (when (null (fastest op))
        (progn
          (setf (fastest op) (subscription op))
          (clear-pairs-without op nil) )
        (on-next (observer op) x) )))


(defmethod on-error ((op operator-amb) x)
  (when (is-active op)
    (set-error op)
    (on-error (observer op) x) ))

(defmethod on-completed ((op operator-amb))
  (when (is-active op)
    (set-completed op)
    (on-completed (observer op)) ))


(defmethod subscribe ((op operator-amb) observer)
  (declare (ignore observer))

  ;; clear old subscriptions, if exists
  (set-disposed op)
  (clear-pairs-without op nil)

  ;; subscribe again
  (dolist (source (sources op))
    (let* ((observer (make-observer
                      ;; on-next
                      #'(lambda (x)
                          (when (not (null (pairs op)))
                            (clear-pairs-without op source) )
                          (on-next (observer op) x) )
                      ;; on-error
                      #'(lambda (x)
                          (set-error op)
                          (on-error (observer op) x) )
                      ;; on-completed
                      #'(lambda ()
                          (set-completed op)
                          (on-completed (observer op))) ))
           (sub (subscribe source observer)) )
      (push (cons source sub) (pairs op)) ))

  (call-next-method) )

(set-rest-arg-operator 'amb 'make-operator-amb)
