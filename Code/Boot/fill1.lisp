(cl:in-package #:sicl-boot)

(defun define-class-prototype (r)
  (setf (sicl-genv:fdefinition 'sicl-clos:class-prototype r)
	#'closer-mop:class-prototype))

(defun define-generic-function-method-class (r)
  (setf (sicl-genv:fdefinition 'sicl-clos:generic-function-method-class
			       r)
	#'closer-mop:generic-function-method-class))

(defun fill1 (boot)
  (let ((c (c1 boot))
	(r (r1 boot)))
    (define-ensure-generic-function c r)
    (define-make-instance c r)
    (define-class-prototype r)
    (define-generic-function-method-class r)
    (ld "../CLOS/ensure-class-using-class-support.lisp" c r)
    (ld "ensure-class-temporary-defun.lisp" c r)
    (ld "../CLOS/standard-object-defclass.lisp" c r)
    (ld "../CLOS/metaobject-defclass.lisp" c r)
    (ld "../CLOS/method-defclass.lisp" c r)
    (ld "../CLOS/standard-method-defclass.lisp" c r)
    (ld "../CLOS/standard-accessor-method-defclass.lisp" c r)
    (ld "../CLOS/standard-reader-method-defclass.lisp" c r)
    (ld "../CLOS/standard-writer-method-defclass.lisp" c r)
    (ld "../CLOS/slot-definition-defclass.lisp" c r)
    (ld "../CLOS/standard-slot-definition-defclass.lisp" c r)
    (ld "../CLOS/direct-slot-definition-defclass.lisp" c r)
    (ld "../CLOS/effective-slot-definition-defclass.lisp" c r)
    (ld "../CLOS/standard-direct-slot-definition-defclass.lisp" c r)
    (ld "../CLOS/standard-effective-slot-definition-defclass.lisp" c r)
    (ld "../CLOS/specializer-defclass.lisp" c r)
    (ld "../CLOS/eql-specializer-defclass.lisp" c r)
    (ld "../CLOS/class-unique-number-defparameter.lisp" c r)
    (ld "../CLOS/class-defclass.lisp" c r)
    (ld "../CLOS/forward-referenced-class-defclass.lisp" c r)
    (ld "../CLOS/real-class-defclass.lisp" c r)
    (ld "../CLOS/regular-class-defclass.lisp" c r)
    (ld "../CLOS/standard-class-defclass.lisp" c r)
    (ld "../CLOS/funcallable-standard-class-defclass.lisp" c r)
    (ld "../CLOS/built-in-class-defclass.lisp" c r)
    (ld "function-temporary-defclass.lisp" c r)
    (ld "../CLOS/funcallable-standard-object-defclass.lisp" c r)
    (ld "../CLOS/generic-function-defclass.lisp" c r)
    (ld "../CLOS/standard-generic-function-defclass.lisp" c r)))
