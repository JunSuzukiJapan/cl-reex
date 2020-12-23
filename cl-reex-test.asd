#|
  This file is a part of cl-reex project.
|#

(defsystem "cl-reex-test"
  :defsystem-depends-on ("prove-asdf")
  :author ""
  :license ""
  :depends-on ("cl-reex"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "cl-reex"))))
  :description "Test system for cl-reex"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
