(in-package :cl-user)
(defpackage cl-reex.subject.subject
  (:use :cl)
  (:import-from :cl-reex.observer
        :on-next
        :on-error
        :on-completed
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
           :disposable-subject ))

(in-package :cl-reex.subject.subject)

(defclass subject (observer observable-object)
  ((observers :initarg :observers
              :initform nil
              :accessor observers )))

(defun make-subject ()
  (make-instance 'subject) )

#|
  (let ((sub (make-instance 'subject)))
    (set-on-next
      #'(lambda (x)
          (when (is-active sub)
            (dolist (observer (observers sub))
              (on-next observer x) )))
      sub )
    (set-on-error
      #'(lambda (x)
          (when (is-active sub)
            (set-error sub)
            (dolist (observer (observers sub))
              (on-error observer x) )))
      sub )
    (set-on-completed
      #'(lambda ()
          (when (is-active sub)
            (set-completed sub)
            (dolist (observer (observers sub))
              (on-completed observer) )))
      sub )
    sub ))
|#


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

