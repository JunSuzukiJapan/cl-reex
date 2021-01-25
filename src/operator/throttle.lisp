(in-package :cl-user)
(defpackage cl-reex.operator.throttle
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
        :set-one-arg-operator )
  (:import-from :cl-reex.operator
        :operator
        :subscription
        :disposable-operator )
  (:export :operator-throttle
        :throttle
        :make-operator-throttle ))

(in-package :cl-reex.operator.throttle)

;;
;; class operator-throttle
;;
(defclass operator-throttle (operator)
  ((interval :initarg :interval
             :accessor interval )
   (thread :initarg :thread
           :accessor thread )
   (item :initarg :item
         :accessor item )
   (has-item :initarg :has-item
             :initform nil
             :accessor has-item )
   (gate :initarg :gate
         :initform (bt:make-lock)
         :accessor gate )
   (need-reset :initarg :need-reset
               :initform nil
               :accessor need-reset )
   (interval-count :initarg :interval-count
                   :initform 0
                   :accessor interval-count )))

(defparameter *magnification* 10)

(defun kill-thread (op)
  (when (and (slot-boundp op 'thread)
             (bt:thread-alive-p (thread op)) )
    (bt:destroy-thread (thread op))
    (setf (thread op) nil)
    (setf (has-item op) nil)
    (setf (need-reset op) nil)
    (setf (interval-count op) 0) ))

(defun reset-sleep (op)
  (setf (need-reset op) t) )

(defmethod cleanup-operator ((op operator-throttle))
  (kill-thread op) )

(defmethod on-next ((op operator-throttle) x)
  (when (is-active op)
    (let ((gate (gate op)))
      (bt:with-lock-held (gate)
        (setf (item op) x)
        (setf (has-item op) t)
        (reset-sleep op) ))))

(defmethod on-error ((op operator-throttle) x)
  (when (is-active op)
    (kill-thread op)
    (on-error (observer op) x)
    (set-error op) ))

(defmethod on-completed ((op operator-throttle))
  (when (is-active op)
    (kill-thread op)
    (on-completed (observer op))
    (set-completed op) ))

(defmethod subscribe ((op operator-throttle) observer)
  (setf (has-item op) nil)
  (setf (need-reset op) nil)
  (setf (interval-count op) 0)
  (setf (thread op)
        (bt:make-thread (lambda ()
                          (let ((interval (interval op)))
                            (loop
                              (sleep (/ interval *magnification*))
                              (let ((gate (gate op))
                                    (call-on-next-p nil)
                                    (item) )
                                (bt:with-lock-held (gate)
                                  (if (need-reset op)
                                      (progn
                                        (setf (need-reset op) nil)
                                        (setf (interval-count op) 0) )
                                      (progn
                                        (incf (interval-count op))
                                        (when (and (>= (interval-count op) *magnification*)
                                                   (has-item op) )
                                          (setf item (item op))
                                          (setf (interval-count op) 0)
                                          (setf (has-item op) nil)
                                          (setf call-on-next-p t) ))))
                                (when call-on-next-p
                                  (bt:make-thread (lambda ()
                                                    (on-next (observer op) item) )))))))))

  (call-next-method) )


;;
;; make operator
;;
(defun make-operator-throttle (observable arg)
  (make-instance 'operator-throttle
                 :observable observable
                 :interval arg ))

;; set to operator-table
(set-one-arg-operator 'throttle 'make-operator-throttle)

