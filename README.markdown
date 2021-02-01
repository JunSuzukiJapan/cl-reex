[![Build Status](https://travis-ci.org/JunSuzukiJapan/cl-reex.svg?branch=main)](https://travis-ci.org/JunSuzukiJapan/cl-reex)


# cl-reex

Reactive extensions for common lisp.

## Installation

Clone this repository to your ```ql:*local-project-directories*```

or use [Roswell](https://github.com/roswell/roswell):

```
$ ros install JunSuzukiJapan/cl-reex
```

```lisp
(ql:quickload :cl-reex)
```

## Examples

subscribe example:

```lisp
(defparameter observer (rx:make-observer
	(rx:on-next (x) (print x))
	(rx:on-error (x) (format t "error: ~S~%" x))
	(rx:on-completed () (print "completed")) ))

(rx:subscribe (rx:observable-from '(1 2 3 4 5)) observer)
```


operator example:

```lisp
(defparameter observer (rx:make-observer
	(rx:on-next (x) (print x))
	(rx:on-error (x) (format t "error: ~S~%" x))
	(rx:on-completed () (print "completed")) ))

(rx:with-observable (rx:observable-from '(1 2 3 4 5 6 7 8 9 10))
   (rx:where (x) (evenp x))
   (rx:where (x) (eq (mod x 3) 0))
   (rx:subscribe observer) )

(rx:with-observable (rx:observable-from #(1 2 3 4 5))
  (rx:where (x) (oddp x))
  (rx:select (x) (* x 3))
  (rx:subscribe observer)
  (rx:dispose) )
```

## Factory methods

### observable-from

```lisp
; list
(rx:observable-from '(1 2 3 4 5))

; array
(rx:observable-from #(1 2 3 4 5))

; string
(rx:observable-from "Hello, world!")

; stream
(defparameter stream (make-string-input-stream "Hello"))
(rx:observable-from stream)
```

### observable-range

```lisp
(defparameter from 1)
(defparameter count 10)
(rx:observable-range from count)
```

### observable-just

```lisp
(rx:observable-just 1)
```

### observable-repeat

```lisp
(defparameter item 1)
(defparameter count 10)
(rx:observable-repeat item count)
```

### observable-of

```lisp
(rx:observable-of 1 2 3 "4" "5" some-object)
```

### observable-empty

```lisp
(rx:observable-empty)
```

### observable-never

```lisp
(rx:observable-never)
```

### observable-throw

```lisp
(rx:observable-throw some-error)
```

### observable-timer

```lisp
(rx:observable-timer second)
(rx:observable-timer second interval-second)
```

### observable-interval

```lisp
(rx:observable-interval second)
```

### observable-amb

```lisp
(rx:observable-amb
  (rx:observable-timer 0.1)
  (rx:observable-timer 0.05) )
```

### observable-merge

```lisp
(rx:observable-merge (rx:observable-of
                      (rx:observable-range 0 3)
                      (rx:observable-range 10 3)
                      (rx:observable-range 20 3) ))
```

### observable-start

```lisp
(rx:observable-start
  (format t "Begin~%")
  (sleep 0.1)
  (format t "End~%") )
```

### handmade-observable

```lisp
(rx:handmade-observable
  (rx:on-next 1)
  (rx:on-next 2)
  (rx:on-error some-error)
  (rx:on-next 3)
  (rx:on-completed) )
```


## Observer

```lisp
(defparameter observer (rx:make-observer
	(rx:on-next (x) (print x))
	(rx:on-error (x) (format t "error: ~S~%" x))
	(rx:on-completed () (print "completed")) ))
```

## Subject

### subject

```lisp
(rx:make-subject)
```

### async-subject

```lisp
(rx:make-async-subject)
```

### behavior-subject

```lisp
(rx:make-behavior-subject 0)
```

### replay-subject

```lisp
(rx:make-replay-subject)
```

## Operators

| Operator | Example |
|----|----|
| All | (rx:all (x) (evenp x)) |
| Amb | (rx:amb some-observable) |
| Any | (rx:any (x) (evenp x)) |
| Average | (rx:average) |
| Catch* | (rx:catch* (condition divison-by-zero) ...) |
| Combine-Latest | (rx:combine-latest some-observable) |
| Concat | (rx:concat) or (rx:concat some-observables) |
| Contains | (rx:contains 1) |
| Count | (rx:count (x) (evenp x)) |
| Default-If-Empty | (rx:default-if-empty default-value) |
| Distinct | (rx:distinct) |
| Do | (rx:do (on-next (x) ...) (on-error (x) ...) (on-completed () ...)) |
| Element-At | (rx:element-at 0) |
| Finally | (rx:finally #'(lambda () ...)) |
| First | (rx:first) or (rx:first (x) (evenp x)) |
| Foreach | (rx:foreach observable #'(lambda (x) ...)) |
| Group-By | (rx:group-by (x) (mod x 3)) |
| Group-By-Until | (rx:group-by-until (x) (mod x 3) ...) |
| Ignore-Elements | (rx:ignore-elements) |
| Last | (rx:last) or (rx:last (x) (evenp x)) |
| Max | (rx:max) |
| Merge | (rx:merge some-observable) |
| Min | (rx:min) |
| Reduce | (rx:reduce (x y) (+ x y)) or (rx:reduce :init 1 (x y) (+ x y)) |
| Repeat | (rx:repeat 10) |
| Sample | (rx:sample seconds) or (rx:sample (observable-interval 0.2)) |
| Scan | (rx:scan (x y) (+ x y)) or (rx:scan :init 100 (x y) (+ x y)) |
| Select | (rx:select (x) (* x x)) |
| Select-Many | (rx:select-many (x) ...) |
| Sequence-Equalp | (rx:sequence-equalp (rx:observable-of 1 2 3 4 5)) |
| Skip | (rx:skip 3) |
| Skip-Last | (rx:skip-last 3) |
| Skip-Until | (rx:skip-until trigger-observable) |
| Skip-While | (rx:skip-while (x) (< x 10)) |
| Sum | (rx:sum) |
| Switch | (rx:switch) |
| Synchronize | (rx:synchronize) |
| Take | (rx:take 3) |
| Take-Last | (rx:take-last 3) |
| Take-Until | (rx:take-unitl trigger-observable) |
| Take-While | (rx:take-while (x) (< x 10)) |
| Throttle | (rx:throttle seconds) |
| To-Array | (rx:to-array) |
| To-List | (rx:to-list) |
| Where | (rx:where (x) (evenp x)) |
| Zip | (rx:zip some-observable) |



## LICENSE

[MIT](LICENSE)