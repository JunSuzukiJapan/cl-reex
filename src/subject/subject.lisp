(in-package :cl-user)
(defpackage cl-reex.subject.subject
  (:use :cl)
  (:import-from :cl-reex.observer
        :on-next
        :on-error
        :on-completed
        :make-observer
        :observer)
  (:import-from :cl-reex.observable
        :observable
        :observable-object
        :is-active
        :set-error
        :set-completed
        :set-disposed
        :subscribe
        :dispose)
  (:export :subject
           :make-subject
           :observers
           :as-observable
           :disposable-subject ))

(in-package :cl-reex.subject.subject)

(defclass subject (observer observable-object)
  ((observers :initarg :observers
              :initform nil
              :accessor observers )))

(defun make-subject ()
  (make-instance 'subject) )


(defmethod on-next ((sub subject) x)
  (when (is-active sub)
    (dolist (observer (observers sub))
      (on-next observer x) )))

(defmethod on-error ((sub subject) x)
  (when (is-active sub)
    (set-error sub)
    (dolist (observer (observers sub))
      (on-error observer x) )))

(defmethod on-completed ((sub subject))
  (when (is-active sub)
    (set-completed sub)
    (dolist (observer (observers sub))
      (on-completed observer) )))

;;
;; Dispose
;;
(defclass disposable-subject ()
  ((subject :initarg :subject
            :accessor subject)
   (observer :initarg :observer
             :accessor observer) ))

(defmethod dispose ((dis-sub disposable-subject))
  (let ((deleted (delete (observer dis-sub) (observers (subject dis-sub)))))
    (setf (observers (subject dis-sub)) deleted) ))

;;
;; Subscribe
;;
(defmethod subscribe ((sub subject) observer)
  (handler-bind
      ((error #'(lambda (condition)
                  (on-error observer condition)
                  (return-from subscribe
                    (make-instance 'disposable-do-nothing
                                   :observable sub
                                   :observer observer )))))
    (push observer (observers sub))
    (make-instance 'disposable-subject
                   :subject sub
                   :observer observer )))

;;
;; as-observable
;;
(defgeneric as-observable (obj))

(defclass subject-as-observable-wrapper (observable-object)
  ((subject :initarg :subject
            :accessor subject )))

(defclass disposable-subject-as-observable-wrapper ()
  ((wrapper :initarg :wrapper
            :accessor wrapper )
   (subscription :initarg :subscription
                 :accessor subscription )))

(defmethod dispose ((disp disposable-subject-as-observable-wrapper))
  (when (slot-boundp disp 'subscription)
    (dispose (subscription disp))
    (slot-unbound 'disposable-subject-as-observable-wrapper disp 'subscription) )
  (set-disposed disp) )


(defmethod as-observable ((sub subject))
  (make-instance 'subject-as-observable-wrapper
                 :subject sub ))

(defmethod subscribe ((wrapper subject-as-observable-wrapper) observer)
  (let* ((temp-observer (make-observer
                         (on-next (x) (on-next observer x))
                         (on-error (x) (on-error observer x))
                         (on-completed () (on-completed observer)) ))
         (subscription (subscribe (subject wrapper) temp-observer)) )
    (make-instance 'disposable-subject-as-observable-wrapper
                   :wrapper wrapper
                   :subscription subscription )))
