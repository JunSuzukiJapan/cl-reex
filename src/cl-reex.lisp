(in-package :cl-user)
(defpackage cl-reex
  (:nicknames :rx)
  (:use :cl)
  (:import-from :cl-reex.observer
        :observer
        :make-observer
        :on-next
        :on-error
        :on-completed )
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
        :observable-of
        :observable-empty
        :observable-never
        :observable-throw
        :foreach )
  (:import-from :cl-reex.error-conditions
                :sequence-contains-no-elements-error
                :argument-out-of-range-exception )
  (:import-from :cl-reex.fixed-size-queue
        :queue
        :make-queue
        :enqueue
        :dequeue
        :is-empty
        :elements-count
        :size )
  (:import-from :cl-reex.operator
        :operator
        :predicate
        :func )
  (:import-from :cl-reex.macro.operator-table
        :get-operator-expander
        :set-operator-expander )
  (:import-from :cl-reex.operator.where
        :where )
  (:import-from :cl-reex.operator.select
        :select )
  (:import-from :cl-reex.operator.take
        :take )
  (:import-from :cl-reex.operator.take-while
        :take-while )
  (:import-from :cl-reex.operator.take-until
        :take-until )
  (:import-from :cl-reex.operator.take-last
        :take-last )
  (:import-from :cl-reex.operator.skip
        :skip )
  (:import-from :cl-reex.operator.skip-while
        :skip-while )
  (:import-from :cl-reex.operator.skip-until
        :skip-until )
  (:import-from :cl-reex.operator.skip-last
        :skip-last )
  (:import-from :cl-reex.operator.repeat
        :repeat )
  (:import-from :cl-reex.operator.first
        :first )
  (:import-from :cl-reex.operator.last
        :last )
  (:import-from :cl-reex.operator.ignore-elements
        :ignore-elements)
  (:import-from :cl-reex.operator.distinct
        :distinct
        :distinct-until-changed )
  (:import-from :cl-reex.operator.finally
        :finally )
  (:import-from :cl-reex.operator.catch-star
        :catch* )
  (:import-from :cl-reex.operator.element-at
        :element-at )
  (:import-from :cl-reex.operator.do
        :do )
  (:import-from :cl-reex.operator.sum
        :sum )
  (:import-from :cl-reex.operator.average
        :average )
  (:import-from :cl-reex.operator.max
        :max )
  (:import-from :cl-reex.operator.min
        :min )
  (:import-from :cl-reex.operator.count
        :count )
  (:import-from :cl-reex.operator.reduce
        :reduce )
  (:import-from :cl-reex.operator.scan
        :scan )
  (:import-from :cl-reex.operator.concat
        :concat )
  (:import-from :cl-reex.subject.subject
        :subject
        :make-subject )
  (:import-from :cl-reex.subject.behavior-subject
        :behavior-subject
        :make-behavior-subject )
  (:import-from :cl-reex.subject.async-subject
        :async-subject
        :make-async-subject )
  (:import-from :cl-reex.subject.replay-subject
        :replay-subject
        :make-replay-subject )
  (:import-from :cl-reex.macro
        :with-observable )
  (:import-from :cl-reex.macro.handmade-observable
        :handmade-observable )
  (:export :subscribe
        :queue
        :make-queue
        :enqueue
        :dequeue
        :is-empty
        :size
        :dispose
        :sequence-contains-no-elements-error
        :argument-out-of-range-exception
        :foreach
        :observable
        :observable-range
        :observable-just
        :observable-repeat
        :observable-from
        :observable-timer
        :observable-interval
        :observable-of
        :observable-empty
        :observable-never
        :observable-throw
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
        :handmade-observable
        :where
        :select
        :repeat
        :take
        :take-while
        :take-until
        :take-last
        :skip
        :skip-while
        :skip-until
        :skip-last
        :first
        :last
        :operator-where
        :ignore-elements
        :distinct
        :distinct-until-changed
        :finally
        :catch*
        :element-at
        :do
        :sum
        :average
        :max
        :min
        :count
        :reduce
        :scan
        :concat
        :subject
        :make-subject
        :behavior-subject
        :make-behavior-subject
        :async-subject
        :make-async-subject
        :replay-subject
        :make-replay-subject ))

(in-package :cl-reex)

