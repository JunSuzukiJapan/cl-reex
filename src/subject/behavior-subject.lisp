(in-package :cl-user)
(defpackage cl-reex.subject.behavior-subject
  (:use :cl)
  (:import-from :cl-reex.observable
        :observable
        :observable-object
        :is-active
        :observable-state
        :state
        :active
        :error
        :completed
        :disposed
        :set-error
        :set-completed
        :set-disposed
        :on-next
        :on-error
        :on-completed
        :get-on-next
        :set-on-next
        :get-on-error
        :set-on-error
        :get-on-completed
        :set-on-completed
        :subscribe
        :dispose)
  (:import-from :cl-reex.observer
        :observer)
  (:import-from :cl-reex.subject.subject
        :subject
        :make-subject
        :observers
        :disposable-subject )
  (:export :behavior-subject
        :make-behavior-subject ))

(in-package :cl-reex.subject.behavior-subject)

(defclass behavior-subject (subject)
  ((current-item :initarg :current-item
                 :accessor current-item )
   (error-item :initarg :error-item
               :accessor error-item )))

(defun make-behavior-subject (item)
  (let ((sub (make-instance 'behavior-subject
                            :current-item item )))
    (set-on-next
      #'(lambda (x)
          (when (is-active sub)
            (setf (current-item sub) x)
            (dolist (observer (observers sub))
              (funcall (get-on-next observer) x) )))
      sub )
    (set-on-error
      #'(lambda (x)
          (when (is-active sub)
            (set-error sub)
            (dolist (observer (observers sub))
              (funcall (get-on-error observer) x) )))
      sub )
    (set-on-completed
      #'(lambda ()
          (when (is-active sub)
            (set-completed sub)
            (dolist (observer (observers sub))
              (funcall (get-on-completed observer)) )))
      sub )
    sub ))

;;
;; Subscribe
;;
(defmethod subscribe ((sub behavior-subject) observer)
  (case (state sub)
    ((active) (funcall (get-on-next observer) (current-item sub)))
    ((error)  (funcall (get-on-next observer) (current-item sub))
              (funcall (get-on-error observer) (error-item sub)) )
    ((completed) (funcall (get-on-completed observer))) )
  (call-next-method) )

