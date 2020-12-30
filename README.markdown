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
(defvar observer (rx:make-observer
	#'(lambda (x) (print x))
	#'(lambda (x) (format t "error: ~S" x))
	#'(lambda () (print "completed")) ))

(rx:subscribe (rx:observable-from '(1 2 3 4 5)) observer)
```


operator example:

```lisp
(defvar observer (rx:make-observer
	#'(lambda (x) (print x))
	#'(lambda (x) (format t "error: ~S" x))
	#'(lambda () (print "completed")) ))

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

: string
(rx:observable-from "Hello, world!")

; stream
(defvar stream (make-string-input-stream "Hello"))
(rx:observable-from stream)
```

### observable-range

```lisp
(defvar from 1)
(defvar count 10)
(rx:observable-range from count)
```

### observable-just

```lisp
(rx:observable-just 1)
```

### observable-repeat

```lisp
(defvar item 1)
(defvar count 10)
(rx:observable-repeat item count)
```

## Observer

```lisp
(defvar observer (rx:make-observer
	#'(lambda (x) (print x))
	#'(lambda (x) (format t "error: ~S" x))
	#'(lambda () (print "completed")) ))
```

## Operators

| Operator | Example |
|----|----|
| Where | (rx:where (x) (evenp x)) |
| Select | (rx:select (x) (* x x)) |
| Repeat | (rx:repeat 10) |
| Take | (rx:take 3) |
| Skip | (rx:skip 3) |


## LICENSE

[MIT](LICENSE)