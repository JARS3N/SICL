(cl:in-package #:sicl-boot)

(defun define-add-remove-direct-subclass (eb)
  (load-source "CLOS/add-remove-direct-subclass-support.lisp" eb)
  (load-source "CLOS/add-remove-direct-subclass-defgenerics.lisp" eb)
  (load-source "CLOS/add-remove-direct-subclass-defmethods.lisp" eb))

(defun define-add-remove-method (eb)
  (load-source "CLOS/add-remove-method-defgenerics.lisp" eb)
  (load-source "CLOS/add-remove-method-support.lisp" eb)
  (load-source "CLOS/add-remove-method-defmethods.lisp" eb))

(defun define-add-remove-direct-method (eb)
  (load-source "CLOS/add-remove-direct-method-defgenerics.lisp" eb)
  (load-source "CLOS/add-remove-direct-method-support.lisp" eb)
  (load-source "CLOS/add-remove-direct-method-defmethods.lisp" eb))

(defun define-reader/writer-method-class (ea eb)
  (with-straddled-function-definitions
      ((sicl-clos::reader-method-class-default
        sicl-clos::writer-method-class-default)
       eb)
    (load-source "CLOS/reader-writer-method-class-support.lisp" ea))
  (load-source "CLOS/reader-writer-method-class-defgenerics.lisp" eb)
  (load-source "CLOS/reader-writer-method-class-defmethods.lisp" eb))

(defun define-direct-slot-definition-class (ea eb)
  (with-straddled-function-definitions
      ((sicl-clos::direct-slot-definition-class-default)
       eb)
    (load-source "CLOS/direct-slot-definition-class-support.lisp" ea))
  (load-source "CLOS/direct-slot-definition-class-defgeneric.lisp" eb)
  (load-source "CLOS/direct-slot-definition-class-defmethods.lisp" eb))

(defun define-find-or-create-generic-function (eb ec)
  (setf (sicl-genv:fdefinition 'sicl-clos::find-or-create-generic-function eb)
        (lambda (name lambda-list)
          (declare (ignore lambda-list))
          (sicl-genv:fdefinition name ec))))

(defun define-validate-superclass (eb)
  (load-source "CLOS/validate-superclass-defgenerics.lisp" eb)
  (load-source "CLOS/validate-superclass-defmethods.lisp" eb))

(defun define-dependent-protocol (eb)
  (setf (sicl-genv:fdefinition 'sicl-clos:map-dependents eb)
        (constantly nil))
  (setf (sicl-genv:fdefinition 'sicl-clos:update-dependent eb)
        (constantly nil)))

(defun define-ensure-class (eb)
  (load-source "CLOS/ensure-class-using-class-support.lisp" eb)
  (load-source "CLOS/ensure-class-using-class-defgenerics.lisp" eb)
  (load-source "CLOS/ensure-class-using-class-defmethods.lisp" eb)
  (load-source "Environment/find-class-defun.lisp" eb)
  (load-source "Environment/standard-environment-functions.lisp" eb)
  (load-source "CLOS/ensure-class.lisp" eb))

(defun enable-class-initialization (ea eb ec)
  (setf (sicl-genv:fdefinition 'typep eb)
        (lambda (object type)
          (sicl-genv:typep object type eb)))
  (define-validate-superclass eb)
  (define-direct-slot-definition-class ea eb)
  (define-add-remove-direct-subclass eb)
  (setf (sicl-genv:special-variable 'sicl-clos::*class-t* eb t) nil)
  (define-add-remove-method eb)
  (load-source "CLOS/add-accessor-method.lisp" eb)
  (define-find-or-create-generic-function eb ec)
  (load-source "CLOS/default-superclasses-defgeneric.lisp" eb)
  (load-source "CLOS/default-superclasses-defmethods.lisp" eb)
  (load-source "CLOS/class-initialization-support.lisp" eb)
  (load-source "CLOS/class-initialization-defmethods.lisp" eb)
  (load-source "CLOS/reinitialize-instance-defgenerics.lisp" eb)
  (define-ensure-class eb)
  ;; FIXME: load files containing the definition instead.
  (setf (sicl-genv:fdefinition 'sicl-clos:add-direct-method eb)
        (constantly nil))
  (define-dependent-protocol eb)
  (define-reader/writer-method-class ea eb))
