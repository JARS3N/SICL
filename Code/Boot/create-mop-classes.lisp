(cl:in-package #:sicl-boot)

(defun create-mop-classes (ea)
  (load-source "CLOS/t-defclass.lisp" ea)
  (setf (sicl-genv:special-variable 'sicl-clos::*class-t* ea t)
        (sicl-genv:find-class 't ea))
  (load-source "CLOS/function-defclass.lisp" ea)
  (load-source "CLOS/standard-object-defclass.lisp" ea)
  (load-source "CLOS/metaobject-defclass.lisp" ea)
  (load-source "CLOS/method-defclass.lisp" ea)
  (load-source "CLOS/standard-method-defclass.lisp" ea)
  (load-source "CLOS/standard-accessor-method-defclass.lisp" ea)
  (load-source "CLOS/standard-reader-method-defclass.lisp" ea)
  (load-source "CLOS/standard-writer-method-defclass.lisp" ea)
  (load-source "CLOS/slot-definition-defclass.lisp" ea)
  (load-source "CLOS/standard-slot-definition-defclass.lisp" ea)
  (load-source "CLOS/direct-slot-definition-defclass.lisp" ea)
  (load-source "CLOS/effective-slot-definition-defclass.lisp" ea)
  (load-source "CLOS/standard-direct-slot-definition-defclass.lisp" ea)
  (load-source "CLOS/standard-effective-slot-definition-defclass.lisp" ea)
  (load-source "CLOS/method-combination-defclass.lisp" ea)
  (load-source "CLOS/specializer-defclass.lisp" ea)
  (load-source "CLOS/eql-specializer-defclass.lisp" ea)
  (load-source "CLOS/class-unique-number-defparameter.lisp" ea)
  (load-source "CLOS/class-defclass.lisp" ea)
  (load-source "CLOS/forward-referenced-class-defclass.lisp" ea)
  (load-source "CLOS/real-class-defclass.lisp" ea)
  (load-source "CLOS/regular-class-defclass.lisp" ea)
  (load-source "CLOS/standard-class-defclass.lisp" ea)
  (load-source "CLOS/funcallable-standard-class-defclass.lisp" ea)
  (load-source "CLOS/built-in-class-defclass.lisp" ea)
  (load-source "CLOS/funcallable-standard-object-defclass.lisp" ea)
  (load-source "CLOS/simple-function-defclass.lisp" ea)
  (load-source "CLOS/generic-function-defclass.lisp" ea)
  (load-source "CLOS/standard-generic-function-defclass.lisp" ea)
  (load-source "Cons/cons-defclass.lisp" ea)
  (load-source "Sequence/sequence-defclass.lisp" ea)
  (load-source "Cons/list-defclass.lisp" ea)
  (load-source "Package-and-symbol/symbol-defclass.lisp" ea)
  (load-source "Cons/null-defclass.lisp" ea)
  (load-source "Arithmetic/number-defclass.lisp" ea)
  (load-source "Arithmetic/real-defclass.lisp" ea)
  (load-source "Arithmetic/rational-defclass.lisp" ea)
  (load-source "Arithmetic/integer-defclass.lisp" ea)
  (load-source "Arithmetic/fixnum-defclass.lisp" ea)
  (load-source "Character/character-defclass.lisp" ea)
  (load-source "Compiler/Code-object/code-object-defclass.lisp" ea))
