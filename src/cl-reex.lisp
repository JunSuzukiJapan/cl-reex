(in-package :cl-user)
(defpackage cl-reex
  (:nicknames :rx)
  (:use :cl)
  (:import-from :cl-reex.observable
		:observable
 		:subscribe
		:dispose
		:observable-range
		:observable-just
		:observable-repeat
 		:observable-from
		:observable-timer
		:observable-interval
 		:make-observer
		:foreach)
  (:import-from :cl-reex.observer
 		:observer
 		:on-next
 		:on-error
 		:on-completed)
  (:import-from :cl-reex.operator
		:operator
		:predicate
		:func)
  (:import-from :cl-reex.macro.operator-table
		:get-operator-expander
		:set-operator-expander)
  (:import-from :cl-reex.operator.where
		:where)
  (:import-from :cl-reex.operator.select
		:select)
  (:import-from :cl-reex.operator.take
		:take)
  (:import-from :cl-reex.operator.skip
		:skip)
  (:import-from :cl-reex.operator.repeat
		:repeat)
  (:import-from :cl-reex.subject.subject
		:subject
		:make-subject)
  (:import-from :cl-reex.macro
		:with-observable)
  (:export :subscribe
	   :dispose
	   :foreach
	   :observable
	   :observable-range
	   :observable-just
	   :observable-repeat
 	   :observable-from
	   :observable-timer
	   :observable-interval
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
	   :select
	   :repeat
	   :skip
	   :take
	   :operator-where
	   :subject
	   :make-subject))

(in-package :cl-reex)

