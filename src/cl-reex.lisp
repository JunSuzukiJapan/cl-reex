(in-package :cl-user)
(defpackage cl-reex
  (:nicknames :rx)
  (:use :cl)
  (:import-from :cl-reex.observable
 		:subscribe
		:dispose
 		:observable-from)
  (:import-from :cl-reex.observer
 		:observer
 		:make-observer
 		:on-next
 		:on-error
 		:on-completed)
  (:import-from :cl-reex.operator
		:observable
		:operator
		:predicate)
  (:import-from :cl-reex.operator.where
		:operator-where
		:make-operator-where)
  (:import-from :cl-reex.macro.operator-table
		:get-operator
		:set-operator)
  (:import-from :cl-reex.macro.symbols
		:where )
  (:import-from :cl-reex.macro
		:with-observable)
  (:export :subscribe
	   :dispose
	   :observable
 	   :observable-from
 	   :observer
 	   :make-observer
 	   :on-next
 	   :on-error
 	   :on-completed
	   :operator
	   :predicate
	   :get-operator
	   :set-operator
	   :with-observable
	   :where
	   :operator-where
	   :make-operator-where))

(in-package :cl-reex)

