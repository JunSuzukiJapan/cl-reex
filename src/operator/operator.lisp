(in-package :cl-user)
(defpackage cl-reex.operator
  (:use :cl)
  (:import-from :cl-reex.observer
 		:observer)
  (:export :operator
	   :predicate
	   :func))

(in-package :cl-reex.operator)

;; body

(defclass operator (observer)
  ()
  )

