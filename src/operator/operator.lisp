(in-package :cl-user)
(defpackage cl-reex.operator
  (:use :cl)
  (:import-from :cl-reex.observer
 		:observer
		:on-next
		:on-error
		:on-completed)
  (:import-from :cl-reex.observable
		:subscribe)
  (:import-from :cl-reex.macro.operator-table
		:get-operator
		:set-operator)
  (:import-from :cl-reex.macro.symbols
		:where )
  (:export :operator
	   :observable
	   :predicate
	   :func))

(in-package :cl-reex.operator)

;; body

(defclass operator (observer)
  ()
  )

