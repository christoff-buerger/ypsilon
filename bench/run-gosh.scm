;; gosh run-gosh.scm

(define warmup #t)
(define filename "bench.gosh.out")

(use gauche.time)
(add-load-path "./gambit-benchmarks")
(define bitwise-and logand)
(define bitwise-not lognot)

(define output-port (open-output-string))

(define-syntax time
  (syntax-rules ()
    ((_ expr)
     (let ((result expr) (time-result (time-this 1 (lambda () expr))))
       (let ((real (time-result-real time-result))
             (user (time-result-user time-result))
             (sys (time-result-sys time-result)))
         (format #t "~%;;~10,6f real ~11,6f user ~11,6f sys~%" real user sys)
         (format output-port "\t~s~%" real))
       result))))

(define (run-benchmark name count ok? run-maker . args)
  (format #t "~%;;  ~a (x~a)" (pad-space name 7) count)
  (format output-port "~s" name)
  (let ((run (apply run-maker args)))
      (if warmup (run-bench name 1 ok? run))
      (let ((result (time (run-bench name count ok? run))))
        (and (not (ok? result)) (format #t "~%;; wrong result: ~s~%~%" result)))
      (format #t ";;  ----------------------------------------------------------------")
      (if #f #f)))

(define call-with-output-file/truncate call-with-output-file)

(define fatal-error
  (lambda x
    (format #t "fatal-error: ~s" x)
    (exit)))

(define pad-space
  (lambda (str n)
    (let ((pad (- n (string-length str))))
      (if (<= pad 0)
          str
          (string-append str (make-string pad #\space))))))

(define (run-bench name count ok? run)
  (let loop ((i 0) (result (list 'undefined)))
    (if (< i count)
        (loop (+ i 1) (run))
        result)))

(define load-bench-n-run
  (lambda (name)
    (load (string-append name ".scm"))
    (main)))

(define-macro time-bench
  (lambda (name count)
    `(begin
       (define ,(string->symbol (format #f "~a-iters" name)) ,count)
       (load-bench-n-run ,(symbol->string name)))))

(define (main . x) #f)

(define-syntax FLOATvector-const (syntax-rules () ((_ . lst) (list->vector 'lst))))
(define-syntax FLOATvector? (syntax-rules () ((_ x) (vector? x))))
(define-syntax FLOATvector (syntax-rules () ((_ . lst) (vector . lst))))
(define-syntax FLOATmake-vector (syntax-rules () ((_ n . init) (make-vector n . init))))
(define-syntax FLOATvector-ref (syntax-rules () ((_ v i) (vector-ref v i))))
(define-syntax FLOATvector-set! (syntax-rules () ((_ v i x) (vector-set! v i x))))
(define-syntax FLOATvector-length (syntax-rules () ((_ v) (vector-length v))))
(define-syntax nuc-const (syntax-rules () ((_ . lst) (list->vector 'lst))))
(define-syntax FLOAT+ (syntax-rules () ((_ . lst) (+ . lst))))
(define-syntax FLOAT- (syntax-rules () ((_ . lst) (- . lst))))
(define-syntax FLOAT* (syntax-rules () ((_ . lst) (* . lst))))
(define-syntax FLOAT/ (syntax-rules () ((_ . lst) (/ . lst))))
(define-syntax FLOAT= (syntax-rules () ((_ . lst) (= . lst))))
(define-syntax FLOAT< (syntax-rules () ((_ . lst) (< . lst))))
(define-syntax FLOAT<= (syntax-rules () ((_ . lst) (<= . lst))))
(define-syntax FLOAT> (syntax-rules () ((_ . lst) (> . lst))))
(define-syntax FLOAT>= (syntax-rules () ((_ . lst) (>= . lst))))
(define-syntax FLOATnegative? (syntax-rules () ((_ x) (negative? x))))
(define-syntax FLOATpositive? (syntax-rules () ((_ x) (positive? x))))
(define-syntax FLOATzero? (syntax-rules () ((_ x) (zero? x))))
(define-syntax FLOATabs (syntax-rules () ((_ x) (abs x))))
(define-syntax FLOATsin (syntax-rules () ((_ x) (sin x))))
(define-syntax FLOATcos (syntax-rules () ((_ x) (cos x))))
(define-syntax FLOATatan (syntax-rules () ((_ x) (atan x))))
(define-syntax FLOATsqrt (syntax-rules () ((_ x) (sqrt x))))
(define-syntax FLOATmin (syntax-rules () ((_ . lst) (min . lst))))
(define-syntax FLOATmax (syntax-rules () ((_ . lst) (max . lst))))
(define-syntax FLOATround (syntax-rules () ((_ x) (round x))))
(define-syntax FLOATinexact->exact (syntax-rules () ((_ x) (inexact->exact x))))
(define-syntax GENERIC+ (syntax-rules () ((_ . lst) (+ . lst))))
(define-syntax GENERIC- (syntax-rules () ((_ . lst) (- . lst))))
(define-syntax GENERIC* (syntax-rules () ((_ . lst) (* . lst))))
(define-syntax GENERIC/ (syntax-rules () ((_ . lst) (/ . lst))))
(define-syntax GENERICquotient (syntax-rules () ((_ x y) (quotient x y))))
(define-syntax GENERICremainder (syntax-rules () ((_ x y) (remainder x y))))
(define-syntax GENERICmodulo (syntax-rules () ((_ x y) (modulo x y))))
(define-syntax GENERIC= (syntax-rules () ((_ . lst) (= . lst))))
(define-syntax GENERIC< (syntax-rules () ((_ . lst) (< . lst))))
(define-syntax GENERIC<= (syntax-rules () ((_ . lst) (<= . lst))))
(define-syntax GENERIC> (syntax-rules () ((_ . lst) (> . lst))))
(define-syntax GENERIC>= (syntax-rules () ((_ . lst) (>= . lst))))
(define-syntax GENERICexpt (syntax-rules () ((_ x y) (expt x y))))

(format #t "\n\n;;  GABRIEL\n")
(time-bench browse 600)
(time-bench cpstak 80)
(time-bench ctak 25)
(time-bench dderiv 160000)
(time-bench deriv 320000)
(time-bench destruc 100)
(time-bench diviter 200000)
(time-bench divrec 140000)
(time-bench puzzle 24)
(time-bench tak 1000)
(time-bench takl 70)
(time-bench triangl 2)

(format #t "\n\n;;  ARITHMETIC\n")
(time-bench fft 400)
(time-bench fib 1)
(time-bench fibc 200)
(time-bench fibfp 1)
(time-bench mbrot 20)
(time-bench nucleic 2)
(time-bench pnpoly 40000)
(time-bench sum 10000)
(time-bench sumfp 1200)

(format #t "\n\n;;  MISCELLANEOUS\n")
(time-bench ack 3)
(time-bench boyer 10)
(time-bench nboyer 1)
(time-bench conform 8)
(time-bench earley 60)
(time-bench graphs 20)
(time-bench mazefun 200)
(time-bench nqueens 450)
(time-bench paraffins 100)
(time-bench peval 20)
(time-bench ray 1)
(time-bench scheme 3000)

(newline)
(newline)

(if filename
    (call-with-output-file/truncate
      filename
      (lambda (port)
        (format port "~a" (get-output-string output-port)))))

(exit)