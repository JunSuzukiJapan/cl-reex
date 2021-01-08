(in-package :cl-user)
(defpackage cl-reex-test.logger
  (:use :cl
        :cl-reex
        :prove)
  (:export :logger
        :add
        :result
        :reset)
  (:shadowing-import-from :cl-reex :skip))
(in-package :cl-reex-test.logger)

(defclass logger ()
  ((log :initarg :log
        :initform nil
        :accessor logger-log )))

(defgeneric add (logger item))

(defmethod add ((logger logger) item)
  (push item (logger-log logger)) )

(defgeneric result (logger))

(defmethod result ((logger logger))
  (reverse (logger-log logger)) )

(defgeneric reset (logger))

(defmethod reset ((logger logger))
  (setf (logger-log logger) nil) )
