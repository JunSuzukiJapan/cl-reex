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
		:operator-where
		:make-operator-where)
  (:import-from :cl-reex.macro
		:with-observable
		:where)
  (:export :subscribe
	   :dispose
	   :observable
 	   :observable-from
 	   :observer
 	   :make-observer
 	   :on-next
 	   :on-error
 	   :on-completed
	   :with-observable
	   :where
	   :operator-where
	   :make-operator-where))

(in-package :cl-reex)

