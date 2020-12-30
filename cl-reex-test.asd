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
		 (:test-file "skip-test")
		 (:test-file "repeat-test")
		 )))
  :description "Test system for cl-reex"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
