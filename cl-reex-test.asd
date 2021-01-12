#|
  This file is a part of cl-reex project.
|#

(defsystem "cl-reex-test"
  :defsystem-depends-on ("prove-asdf")
  :author ""
  :license ""
  :depends-on ("prove")
  :components ((:module "tests"
    :components
      ((:file "logger")
       (:test-file "logger-test")
       (:test-file "subscribe-test")
       (:test-file "where-test")
       (:test-file "select-test")
       (:test-file "take-test")
       (:test-file "take-while-test")
       (:test-file "skip-test")
       (:test-file "skip-while-test")
       (:test-file "repeat-test")
       (:test-file "subject-test")
       (:test-file "foreach-test")
       (:test-file "observable-test")
       (:test-file "observable-timer-test")
       (:test-file "handmade-observable-test")
       (:test-file "take-until-test")
       (:test-file "skip-until-test")
       (:test-file "first-test")
       (:test-file "last-test")
       (:test-file "fixed-size-queue-test")
       (:test-file "take-last-test")
       (:test-file "skip-last-test")
       (:test-file "ignore-elements-test")
       (:test-file "distinct-test")
       (:test-file "error-handling-test")
       (:test-file "finally-test")
       (:test-file "catch-test")
	  )))
  :description "Test system for cl-reex"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
